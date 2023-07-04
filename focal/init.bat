@echo off

if ["%~1"]==[""] (
    copy /-y resources\focal.yaml focal.yaml
)

echo focal initialized!
