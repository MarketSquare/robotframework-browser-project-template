*** Settings ***
Suite Setup   Login
Suite Teardown  Logout

*** Keywords ***
Login
    Log  login

Logout
    Log  logout
