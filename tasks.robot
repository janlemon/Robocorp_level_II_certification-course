*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             html_tables.py
Library             RPA.Browser.Selenium    auto_close=${True}
Library             RPA.Tables
Library             RPA.Images
Library             Collections
Library             RPA.PDF
Library             XML
Library             RPA.HTTP
Library             RPA.Robocorp.Vault
Library             OperatingSystem
Library             RPA.FileSystem
Library             RPA.Archive
Library             RPA.Dialogs


*** Tasks ***
Order robots from RobotSpareBin Industries Inc.
    Download CSV Files    input/Download    orders.csv
    Open New Browser
    ${csvDatatable}=    Get Orders    input/Download    orders.csv
    FOR    ${row}    IN    @{csvDatatable}
        Pop Up Window Handling
        Select Head from Select    ${row}[Head]
        Enter Leg Number    ${row}[Legs]
        Enter Shipping Address    ${row}[Address]
        Select Body    ${row}[Body]
        Click to Preview
        Sleep    1
        Make screenshot
        Submit The Order
        ${alertExist}=    Is Element Visible    css:div[class="alert alert-danger"]
        WHILE    ${alertExist}
            Submit The Order
            ${alertExist}=    Is Element Visible    css:div[class="alert alert-danger"]
        END
        Save the receipt    ${row}[Order number]
        Order Another Robot
    END
    ${zipName}=    Input form dialog
    Create a ZIP File    output/pdf    output/${zipName}
    File Should Exist    output/${zipName}


*** Keywords ***
Download CSV Files
    [Arguments]    ${targetFolder}    ${fileName}
    Log    Download the csv file    level=Trace
    ${secret}=    Get Secret    csvURL
    Download    ${secret}[csvURL]    target_file=${targetFolder}    overwrite=True
    Log    ${targetFolder}/${fileName}
    Wait Until Created    ${targetFolder}/${fileName}    timeout=10
    File Should Exist    ${targetFolder}/${fileName}

Open New Browser
    Log    Openning available browser    level=Trace
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True
    Log    Check, if browser was opened properly    level=Trace
    Wait Until Element Is Visible    css:button.btn.btn-dark

Pop Up Window Handling
    Log    Clicking to OK in pop window    level=Trace
    Click Button    css:.btn.btn-dark

Get Orders
    [Arguments]    ${inputFolder}    ${fileName}
    Log    Loading CSV into promt    level=Trace
    ${csvFile}=    Read table from CSV    ${inputFolder}/${fileName}    header=True
    RETURN    ${csvFile}

Get HTML table
    Click Button    css:#root > div > div.container > div > div.col-sm-5 > div.form-group > button
    Sleep    1
    ${html_table}=    Get Element Attribute    css:#model-info    outerHTML
    Log    Data in Table: ${html_table}
    RETURN    ${html_table}

Read HTML table as Table
    Log    Reading HTML table and parsing data    level=Trace
    ${html_table}=    Get HTML table
    Log    Table: ${html_table}    level=Trace
    ${table}=    Read Table From Html    ${html_table}
    RETURN    @{table}

Select Head from Select
    [Arguments]    ${in_headNumber}
    Log    Selecting Head from the list with in_headNumber: ${in_headNumber}    level=Trace
    Select From List By Value    id:head    ${in_headNumber}

Enter Leg Number
    [Arguments]    ${in_legNumber}
    Log    Entering Leg Number: ${in_legNumber}    level=Trace
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${in_legNumber}

Select Body
    [Arguments]    ${in_bodyNumber}
    Log    Selecting Body with the radio Button: ${in_bodyNumber}    level=Trace
    Select Radio Button    body    id-body-${in_bodyNumber}

Enter Shipping Address
    [Arguments]    ${in_shippingAddress}
    Log    Entering Shipping address: ${in_shippingAddress}    level=Trace
    Input Text    css:input[id="address"]    ${in_shippingAddress}

Click to Preview
    Log    Clicking to preview    level=Trace
    Click Button    id:preview

Make screenshot
    Log    Taking screenshot of the robot preview    level=Trace
    Scroll Element Into View    css:img[alt="Legs"]
    Screenshot    css:div[id="robot-preview-image"]    output/robotpreview.png

Submit The Order
    Log    Submiting Order    level=Trace
    Click Button    css:button[id="order"]

Order Another Robot
    Log    Click to Order another Robot button    level=Trace
    Click Button    css:button[id="order-another"]

Save the receipt
    [Arguments]    ${orderNumber}
    Log    Saving receipt    level=Trace
    ${htmlContent}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${htmlContent}    output/pdf/order${orderNumber}.pdf
    ${listOfFiles}=    Create List    output/pdf/order${orderNumber}.pdf    output/robotpreview.png
    Add Files To Pdf    ${listOfFiles}    output/pdf/order${orderNumber}.pdf

Create a ZIP File
    [Arguments]    ${pdfFolderPath}    ${zipName}
    Archive Folder With Zip    ${pdfFolderPath}    ${zipName}    overwrite=True

Input form dialog
    Add heading    Give me the name of the ZIP file
    Add text input    message    label=name
    ${zipName}=    Run dialog
    Log    ${zipName.message}.zip    level=INFO
    RETURN    ${zipName.message}.zip
