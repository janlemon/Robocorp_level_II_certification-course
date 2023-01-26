*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.Tables
Library             html_tables.py
            


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open New Browser
    Pop Up Window Handling
    Read Model Info


*** Keywords ***
Open New Browser
    Log    Openning available browser    level=Trace
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True
    Log    Check, if browser was opened properly    level=Trace
    Wait Until Element Is Visible    css:button.btn.btn-dark
    

Pop Up Window Handling
    Log    Clicking to OK in pop window    level=Trace
    Click Button    css:.btn.btn-dark

Get Orders
    Log    Loading CSV into promt    level=Trace
    ${csvFile}=    Read table from CSV    input/orders.csv    header=True
    RETURN    ${csvFile}

Read Model Info
    Log    Read table Model Info
    ${modelInfo}=    Get WebElements    id:model-info
    Log    ${modelInfo}
