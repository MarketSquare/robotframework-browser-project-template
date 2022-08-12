*** Settings ***
Resource  ../Resources/Common.resource

Suite Setup  Start Test Suite
Test Setup  Start Web Test
Test Teardown  Finish Web Test
Suite Teardown  Finish Test Suite

*** Test Cases ***
TestCaseTitle
    # Author:
    [Documentation]  https://testcases.my-org.com/browse/XY-0001
    [Tags]  Regression  XY-0001
    Go To  https://example.net/
    Wait For Elements State  "Example Domain"  message=The title could not be found

TestCaseLink
    # Author:
    [Documentation]  https://testcases.my-org.com/browse/XY-0002
    [Tags]  Regression  XY-0002
    Go To  https://example.net/
    Wait For Elements State  a >> "More information..."  message=The link could not be found
