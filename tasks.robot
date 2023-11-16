*** Settings ***
Documentation       Template robot main suite.

Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.Excel.Application
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.Robocorp.WorkItems
Library    Screenshot
Library    RPA.PDF

*** Tasks ***
Order Robots from RobotSpareBin Industries Inc
    Open the robot order website    
    Fill the order using CSV File


*** Variables ***

${SS_Path}    D:/Python/RoboCorp - 2/output/screenshot

*** Keywords ***


Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=${True}
    Click Button    OK


Fill the form orders
    [Arguments]    ${head}    ${body}    ${legs}    ${address}
    Sleep    1
    Select From List By Value    id=head    ${head}
    Select Radio Button    body    ${body}
    Input Text    css:input.form-control    ${legs}
    Input Text    id=address    ${address}          


Fill the order using CSV File    
    @{orders} =     Read table from CSV    orders.csv    header=${True}
    FOR    ${element}    IN    @{orders}
        Sleep    1        
        Fill the form orders    ${element['Head']}    ${element['Body']}    ${element['Legs']}    ${element['Address']}
        Wait Until Keyword Succeeds    10x    1s    Submit Form
        Screenshot the robot    ${element['Order number']}
        Create the PDF    ${element['Order number']}
        Concat File    ${element['Order number']}
        Order another robot
    END


Submit Form
    Set Local Variable    ${receipt}    //*[@id="receipt"]
    Wait Until Element Is Visible    id:order
    Click Element    id:order
    Page Should Contain Element    ${receipt}


Order another robot
    Sleep    1
    Wait Until Element Is Visible    id:order-another
    Click Button    id:order-another
    Click Button    OK


Screenshot the robot
    [Arguments]    ${order_number}
    Sleep    1
    Screenshot    id:robot-preview-image    D:/Python/RoboCorp - 2/output/screenshot/${order_number}-robot-preview.png

Create the PDF
    [Arguments]    ${OrderNumber}
    Sleep    1
    Wait Until Element Is Visible    id:receipt
    ${orderhtml}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${orderhtml}    D:/Python/RoboCorp - 2/output/PDF/Robot-${OrderNumber}-receipt.pdf


Concat File
    [Arguments]    ${OrderNumber}
    Sleep    1
    ${ss}=    Create List    ${SS_Path}/${OrderNumber}-robot-preview.png
    Add Files To Pdf    ${ss}    D:/Python/RoboCorp - 2/output/PDF/Robot-${OrderNumber}-receipt.pdf    append=${True}