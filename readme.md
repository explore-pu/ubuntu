# Introduction

PHP development environment based on the official box of Ubuntu, point-and-shoot configuration, easy to manage the
sites

## clone

```shell
git clone https://github.com/explore-pu/ubuntu.git
```

## initialize

```shell
# cd jammy or cd focal
.\init.bat
```

## function

### Add configurable software repositories：`sources`

> Configure the source_list to prevent unavailability due to network issues

```yaml
# Homestead.yaml
sources: "http://cn.archive.ubuntu.com"
ip: "192.168.56.10"
memory: 2048
```

### You can configure the vue site：`type: vue`

### When multi-site, you can configure the IP default site：`default: true`

```yaml
# Homestead.yaml
sites:
  - map: laravel.box
    to: /home/vagrant/code/laravel/public
  - map: vue.box
    to: /home/vagrant/code/vue/dist
    type: vue
  - map: lumen.box
    to: /home/vagrant/code/lumen/public
    default: true
```

> Configure the default site to directly access the corresponding site through IP in the LAN without domain name access
