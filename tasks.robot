*** Settings ***
Documentation       Täytä osto tilaukset
Library    RPA.Browser.Selenium
Library    Collections
Library    RPA.Tables
Library    RPA.HTTP
Library    RPA.Desktop
Library    RPA.Excel.Files
Library    String
*** Variables ***

*** Tasks ***
Avaa nettisivu
    Open Chrome Browser    https://developer.automationanywhere.com/challenges/automationanywherelabs-supplychainmanagement.html    
    Download    https://s3-us-west-2.amazonaws.com/aai-devportal-media/wp-content/uploads/2021/07/09220646/StateAssignments.xlsx    overwrite=True
    ${All_PO_numbers}=    Get PO number
    Login  
    ${Index}=    Set Variable    ${1}
    FOR    ${row}    IN    @{All_PO_numbers}
        ${OrderData}=    Get input data    ${All_PO_numbers}    ${row}    
        Fill purchase orders    ${OrderData}    ${Index}  
        ${Index}=    Evaluate    ${Index}+1
    END
    Click Button    css:#submitbutton
    Wait Until Page Contains Element    css:#myModal > div > div > div.modal-header > div.container
    Sleep    0.5s
    Capture Element Screenshot    css:#myModal > div > div > div.modal-header > div.container    Result.png
       

*** Keywords ***

Get PO number
    ${PO_number1}=    Get Value    css:#PONumber1
    ${PO_number2}=    Get Value    css:#PONumber2
    ${PO_number3}=    Get Value    css:#PONumber3
    ${PO_number4}=    Get Value    css:#PONumber4
    ${PO_number5}=    Get Value    css:#PONumber5
    ${PO_number6}=    Get Value    css:#PONumber6
    ${PO_number7}=    Get Value    css:#PONumber7
    ${All_PO_numbers}=    Create List    ${PO_number1}    ${PO_number2}   ${PO_number3}   ${PO_number4}   ${PO_number5}   ${PO_number6}   ${PO_number7}
    

    RETURN   ${All_PO_numbers}

Login
    Open Chrome Browser    https://developer.automationanywhere.com/challenges/AutomationAnywhereLabs-POTrackingLogin.html    
    Sleep    1s
    ${Cookies}=    Does Page Contain Button    css:#onetrust-accept-btn-handler
    IF    ${Cookies} == True
        Click Button    css:#onetrust-accept-btn-handler
        Input Text    css:#inputEmail    admin@procurementanywhere.com
        Input Password    css:#inputPassword    paypacksh!p
        
    ELSE
        Input Text    css:#inputEmail    admin@procurementanywhere.com
        Input Password    css:#inputPassword    paypacksh!p
    END 

    Click Button    css:body > div.container > div > div > div > div > form > button.btn.btn-lg.btn-primary.btn-block.text-uppercase

Get input data
    [Arguments]    ${All_PO_numbers}    ${row}

    Switch Browser    2

    Input Text    css:#dtBasicExample_filter > label > input[type=search]    ${row}
    ${ShipDate}=    Get Text    css:#dtBasicExample > tbody > tr > td:nth-child(7)

    ${OrderTotal}=    Get Text    css:#dtBasicExample > tbody > tr > td:nth-child(8)
    ${OrderTotal}=    Replace String    ${OrderTotal}    $    ${EMPTY}

    ${State}=    Get Text    css:#dtBasicExample > tbody > tr > td:nth-child(5)

    Open Workbook    StateAssignments.xlsx
    ${Table}=    Read Worksheet As Table    header=True
    
    @{AgentAndState}=    Find table rows     ${table}    State   ==   ${State}
    ${AgentName}=     Get From Dictionary   ${AgentAndState}[-1]    Full Name

    ${OrderData1}=    Create Dictionary    ShipDate=${ShipDate}    OrderTotal=${OrderTotal}    AgentName=${AgentName}

    RETURN    ${OrderData1}
    
Fill purchase orders
    [Arguments]      ${OrderData1}    ${Index}

    Switch Browser    1
                                                    
    Select From List By Value    css:#agent${Index}    ${OrderData1}[AgentName]
    
    Input Text    css:#shipDate${Index}   ${OrderData1}[ShipDate]

    Input Text    css:#orderTotal${Index}   ${OrderData1}[OrderTotal]

