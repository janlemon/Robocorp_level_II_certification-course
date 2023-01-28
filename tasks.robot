*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             html_tables.py
Library             RPA.Browser.Selenium    auto_close=${True}
Library             RPA.Tables


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open New Browser
    Pop Up Window Handling
    ${html_table}=    Get HTML table
    ${table}=    Read Table From Html    ${html_table}
    ${dimensions}=    Get Table Dimensions    ${table}
    ${first_row}=    Get Table Row    ${table}    ${0}
    ${first_cell}=    RPA.Tables.Get Table Cell    ${table}    ${0}    ${0}
    FOR    ${row}    IN    @{table}
        Log To Console    ${row}
    END

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

Get HTML table
    Click Button    css:#root > div > div.container > div > div.col-sm-5 > div.form-group > button
    Sleep    1
    ${html_table}=    Get Element Attribute    css:#model-info     outerHTML
    Log    Data in Table: ${html_table}
    RETURN    ${html_table}