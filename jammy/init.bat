@echo off

if ["%~1"]==[""] (
    copy /-y resources\jammy.yaml jammy.yaml
)

echo jammy initialized!
