*** Settings ***
Library  BuiltIn
Library  OperatingSystem
Library  String
Library  Browser  auto_closing_level=MANUAL  enable_playwright_debug=${DEBUG}  timeout=${TIME_NORMAL}
...  run_on_failure=Take Screenshot \ ..${/}..${/}fail-screenshot-${PABOTEXECUTIONPOOLID}-{index}

*** Variables ***
# Configuration test variables
${BROWSER}   Edge   # web browser to execute tests in (Chromium / Chrome / Edge)
${HEADLESS}  False  # run in headless mode
${DEBUG}     False  # run in debug mode
${PABOTEXECUTIONPOOLID}  ${EMPTY}  # global Pabot variable for ID pool

${TIME_NORMAL}  10 s  # standard timeout for Browser library

# General constants
${NBSP}  \xA0  # unbreakable space

# Selectors of common elements
*** Keywords ***
# Setups and teardowns #####################################################################################################################

Start Test Suite
    [Documentation]  Executes needed actions before suite's run.
    Set System Dependent Variables
    IF  ${DEBUG}  Set Log Level  TRACE
    IF  not ${HEADLESS} and not ${CONTAINER}  Import Library  Dialogs
    Start Web Browser

Start Web Test
    [Documentation]  Executes needed actions before test's run.
    Open Browser Context
    New Page

Finish Web Test
    [Documentation]  Executes finishing actions after test's run.
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Take Screenshot  ..${/}..${/}${TEST_NAME}-{index}
    IF  ${DEBUG} and not ${HEADLESS} and not ${CONTAINER}
        Run Keyword If Test Failed  Pause Execution  Test ended with error:\n${TEST_MESSAGE}
    END
    Close Context

Finish Test Suite
    [Documentation]  Executes finishing actions after suite's run.
    No Operation

# System and browsers ######################################################################################################################
Set System Dependent Variables
    [Documentation]  Sets global variables' values:\n\n
    ...  - ``SYSTEM``: at which OS we are now (_Windows_, _Linux_, ...)
    ...  - ``SERVER``: whether we are at a server controlled by Jenkins (_True_/_False_)
    ...  - ``CONTAINER``: whether we are in a container controlled by Kubernetes (_True_/_False_)
    ${SYSTEM}  Evaluate  platform.system()  platform
    Set Global Variable  ${SYSTEM}
    ${SERVER}  Set Variable If  "%{NODE_NAME=}"  True  False
    Set Global Variable  ${SERVER}
    ${CONTAINER}  Set Variable If  "%{KUBERNETES_PORT=}"  True  False
    Set Global Variable  ${CONTAINER}
    IF  ${CONTAINER} and not ${HEADLESS}
        Log  Tests launched in container, they will run in headless mode despite the settings  level=WARN
        Set Global Variable  ${HEADLESS}  True
    END

Start Web Browser
    [Documentation]  Starts web browser according to configuration variables.
    ${brows}  Convert To Lower Case  ${BROWSER}
    IF  '${brows}' not in ['chromium', 'chrome', 'edge']
        Fail  Wrong browser is chosen: only Google Chrome, Chromium and Microsoft Edge is supported
    END
    ${chromium_arguments}  Create List  --auth-server-whitelist="_"  --window-position=-7,-7  --pause_on_failure=${DEBUG}
    ${path_to_x86}  Set Variable  C:${/}Program Files (x86)${/}Google${/}Chrome${/}Application${/}chrome.exe
    ${x86_exists}  Run Keyword And Return Status  File Should Exist  ${path_to_x86}
    ${chrome_path}  Set Variable If
    ...  '${SYSTEM}' == 'Linux'                           ${/}usr${/}bin${/}google-chrome
    ...  '${SYSTEM}' == 'Windows' and ${x86_exists}       ${path_to_x86}
    ...  '${SYSTEM}' == 'Windows' and not ${x86_exists}   C:${/}Program Files${/}Google${/}Chrome${/}Application${/}chrome.exe
    ${browser_path}  Set Variable If
    ...  '${brows}' == 'chromium'  ${EMPTY}
    ...  '${brows}' == 'edge'      C:${/}Program Files (x86)${/}Microsoft${/}Edge${/}Application${/}msedge.exe
    ...  '${brows}' == 'chrome'    ${chrome_path}
    New Browser  browser=chromium  executablePath=${browser_path}  headless=${HEADLESS}  args=${chromium_arguments}

Open Browser Context
    [Documentation]  Opens new browser context with specific settings.
    New Context  viewport={'width': 1920, 'height': 960}  # Workaround for window maximalization
    ...          acceptDownloads=True
