# Main Jammy Class
class Jammy
  def self.configure(config, settings)
    # Set The VM Provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

    # Configure Local Variable To Access Scripts From Remote Location
    script_dir = File.dirname(__FILE__)

    # Configure The Box
    config.vm.define settings['name'] ||= 'jammy64'
    config.vm.box = settings['box'] ||= 'ubuntu/jammy64'
    config.vm.hostname = settings['hostname'] ||= 'jammy64'

    # Configure A Private Network IP
    if settings['ip'] != 'autonetwork'
      config.vm.network :private_network, ip: settings['ip'] ||= '192.168.56.56'
    else
      config.vm.network :private_network, ip: '0.0.0.0', auto_network: true
    end

    # Configure A Few VirtualBox Settings
    config.vm.provider 'virtualbox' do |vb|
      vb.name = settings['name'] ||= 'jammy64'
      vb.memory = settings['memory'] ||= '2048'
      vb.cpus = settings['cpus'] ||= '1'
      vb.gui = settings['gui'] ||= false
    end

    # Add Custom Ports From Configuration
    if settings.has_key?('ports')
      settings['ports'].each do |port|
        config.vm.network 'forwarded_port', guest: port['to'], host: port['send'], protocol: port['protocol'] ||= 'tcp', auto_correct: true
      end
    end

    # Configure The Public Key For SSH Access
    if settings.include? 'authorize'
      if File.exist? File.expand_path(settings['authorize'])
        config.vm.provision "setting authorize key", type: "shell" do |s|
          s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/vagrant/.ssh/authorized_keys"
          s.args = [File.read(File.expand_path(settings['authorize']))]
        end
      end
    end

    # Copy The SSH Private Keys To The Box
    if settings.include? 'keys'
      if settings['keys'].to_s.length.zero?
        puts 'Check your .yaml file, you have no private key(s) specified.'
        exit
      end
      settings['keys'].each do |key|
        if File.exist? File.expand_path(key)
          config.vm.provision "setting authorize permissions for #{key.split('/').last}", type: "shell" do |s|
            s.privileged = false
            s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
            s.args = [File.read(File.expand_path(key)),key.split('/').last]
          end
        else
          puts 'Check your .yaml file, the path to your private key does not exist.'
          exit
        end
      end
    end

    # Register All Of The Configured Shared Folders
    if settings.include? 'folders'
      settings['folders'].each do |folder|
        if File.exist? File.expand_path(folder['map'])
          config.vm.synced_folder folder['map'], folder['to']
        else
          config.vm.provision 'shell' do |s|
            s.inline = ">&2 echo \"Unable to mount one of your folders. Please check your folders in .yaml\""
          end
        end
      end
    end

    # Creates folder for opt-in features lock-files
    config.vm.provision "mk_features", type: "shell", inline: "mkdir -p /home/vagrant/.features"
    config.vm.provision "own_features", type: "shell", inline: "chown -Rf vagrant:vagrant /home/vagrant/.features"

    #change software source
    if settings.has_key?('sources')
      config.vm.provision 'shell' do |s|
        s.name = 'Change Software Source'
        s.path = script_dir + '/change-sources.sh'
        s.args = [settings['sources']]
      end
    end

    config.vm.provision "apt_update", type: "shell", inline: "apt-get update && apt-get -y upgrade"

    # Install features
    if settings.has_key?('features')

      settings['features'].each do |feature|
        feature_name = feature.keys[0]
        feature_variables = feature[feature_name]
        feature_path = script_dir + "/features/" + feature_name + ".sh"

        # Check for boolean parameters
        # Compares against true/false to show that it really means "<feature>: <boolean>"
        if feature_variables == false
          config.vm.provision "shell", inline: "echo Ignoring feature: #{feature_name} because it is set to false \n"
          next
        elsif feature_variables == true
          # If feature_arguments is true, set it to empty, so it could be passed to script without problem
          feature_variables = {}
        end

        # Check if feature really exists
        if !File.exist? File.expand_path(feature_path)
          config.vm.provision "shell", inline: "echo Invalid feature: #{feature_name} \n"
          next
        end

        config.vm.provision "shell" do |s|
          s.name = "Installing " + feature_name
          s.path = feature_path
          s.env = feature_variables
        end
      end
    end

    # Enable Services
    if settings.has_key?('services')
      settings['services'].each do |service|
        service['enabled'].each do |enable_service|
          config.vm.provision "enable #{enable_service}", type: "shell", inline: "sudo systemctl enable #{enable_service}"
          config.vm.provision "start #{enable_service}", type: "shell", inline: "sudo systemctl start #{enable_service}"
        end if service.include?('enabled')

        service['disabled'].each do |disable_service|
          config.vm.provision "disable #{disable_service}", type: "shell", inline: "sudo systemctl disable #{disable_service}"
          config.vm.provision "stop #{disable_service}", type: "shell", inline: "sudo systemctl stop #{disable_service}"
        end if service.include?('disabled')
      end
    end

    web = settings['web'] ||= 'apache2'

    # Clear any existing nginx sites
    config.vm.provision 'shell' do |s|
      s.path = script_dir + "/clear-#{web}.sh"
    end

    # Clear any sites and insert markers in /etc/hosts
    config.vm.provision 'shell' do |s|
      s.path = script_dir + '/hosts-reset.sh'
    end

    # Install All The Configured Nginx Sites
    if settings.include? 'sites'

      settings['sites'].each do |site|
        # Create SSL certificate
        config.vm.provision 'shell' do |s|
          s.name = 'Creating Certificate: ' + site['map']
          s.path = script_dir + '/create-certificate.sh'
          s.args = [site['map']]
        end

        default = 'false'
        if site['default'] == true
          default = 'true'
        end

        config.vm.provision 'shell' do |s|
          s.name = 'Creating Site: ' + site['map']

          # Convert the site & any options to an array of arguments passed to the
          # specific site script (defaults to laravel)
          s.path = script_dir + "/sites/#{web}.sh"
          s.args = [
            site['map'],                       # $1
            site['to'],                        # $2
            site['port'] ||= '80',             # $3
            site['ssl'] ||= '443',             # $4
            default,                           # $5
            settings['ip'] ||= '192.168.56.56' # $6
          ]
        end

        config.vm.provision 'shell' do |s|
          s.path = script_dir + "/hosts-add.sh"
          s.args = ['127.0.0.1',site['map']]
        end
      end

      config.vm.provision "shell", inline: "sudo systemctl restart #{web}"
    end

    # Configure All Of The Configured Databases
    if settings.has_key?('databases')
      enabled_databases = Array.new
      # Check which databases are enabled
      if settings.has_key?('features')
        settings['features'].each do |feature|
          feature_name = feature.keys[0]
          feature_arguments = feature[feature_name]

          # If feature is set to false, ignore
          if feature_arguments == false
            next
          end

          enabled_databases.push feature_name
        end
      end

      settings['databases'].each do |db|
        if (enabled_databases.include? 'mysql') || (enabled_databases.include? 'mysql8') || (enabled_databases.include? 'mariadb')
          config.vm.provision 'shell' do |s|
            s.name = 'Creating MySQL / MariaDB Database: ' + db
            s.path = script_dir + '/create-mysql.sh'
            s.args = [db]
          end
        end
      end
    end

    if settings.has_key?('backup') && settings['backup'] && (Vagrant::VERSION >= '2.1.0' || Vagrant.has_plugin?('vagrant-triggers'))
      dir_prefix = '/vagrant/.backup'

      # Rebuild the enabled_databases so we can check before backing up
      enabled_databases = Array.new
      # Check which databases are enabled
      if settings.has_key?('features')
        settings['features'].each do |feature|
          feature_name = feature.keys[0]
          feature_arguments = feature[feature_name]

          # If feature is set to false, ignore
          if feature_arguments == false
            next
          end

          enabled_databases.push feature_name
        end
      end

      # Loop over each DB
      settings['databases'].each do |database|
        # Backup MySQL/MariaDB
        if (enabled_databases.include? 'mysql') || (enabled_databases.include? 'mariadb')
          Jammy.backup_mysql(database, "#{dir_prefix}/mysql_backup", config)
        end
      end
    end
  end

  def self.backup_mysql(database, dir, config)
    now = Time.now.strftime("%Y%m%d%H%M")
    config.trigger.before :destroy do |trigger|
      trigger.warn = "Backing up mysql database #{database}..."
      trigger.run_remote = {inline: "mkdir -p #{dir}/#{now} && mysqldump --routines #{database} > #{dir}/#{now}/#{database}-#{now}.sql"}
    end
  end
end
