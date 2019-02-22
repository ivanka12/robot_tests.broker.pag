*** Settings ***
Library  String
Library  DateTime
Library  pag_service.py


*** Variables ***

${locator.auctionID}                                           css=.auction-auctionID
${locator.title}                                               css=.auction-title
${locator.status}                                              css=.auction-status
${locator.dgfID}                                               css=.auction-dgfId
${locator.dgfDecisionDate}                                     css=.auction-dgfDecisionDate
${locator.dgfDecisionID}                                       css=.auction-dgfDecisionID
${locator.procurementMethodType}                               css=.auction-procurementMethodType
${locator.description}                                         css=.description
${locator.minimalStep.amount}                                  css=.auction-minimalStep-amount
${locator.procuringEntity.name}                                css=.auction-procuringEntity-name
${locator.value.amount}                                        css=.auction-value-amount
${locator.guarantee.amount}                                    css=.auction-guarantee-amount
${locator.value.currency}                                      css=.auction-value-currency
${locator.value.valueAddedTaxIncluded}                         css=.auction-value-tax
${locator.tenderPeriod.startDate}                              css=.tender-period-start
${locator.tenderPeriod.endDate}                                css=.tender-period-end
${locator.auctionPeriod.startDate}                             css=.auction-period-start
${locator.auctionPeriod.endDate}                               css=.auction-period-end
${locator.tenderAttempts}                                      css=.auction-tenderAttempts

${locator.qualificationPeriod.startDate}                        css=.award-period-start
${locator.qualificationPeriod.endDate}                          css=.award-period-end

${locator.enquiryPeriod.startDate}                             css=.enquiry-period-start
${locator.enquiryPeriod.endDate}                               css=.enquiry-period-end
${locator.cancellations[0].status}                             css=.cancellation-status
${locator.cancellations[0].reason}                             css=.cancellation-reason

*** Keywords ***

Підготувати дані для оголошення тендера
  [Arguments]  ${userName}   ${auctionData}  ${roleName}
  ${auctionData}=  prepare_auction         ${auctionData}  ${roleName}
  ${isFinancial}=  is_financial_procedure  ${auctionData}

  Set Global Variable  ${isFinancial}  ${isFinancial}

  [return]  ${auctionData}

Підготувати клієнт для користувача
  [Arguments]   ${userName}
  Set Global Variable    ${isFinancial}        ${None}
  Set Global Variable    ${MODIFICATION_DATE}  ${EMPTY}

  ${alias}=              Catenate   SEPARATOR=   role_  ${userName}
  Set Global Variable    ${BROWSER_ALIAS}   ${alias}
  Open Browser           ${BROKERS['${broker}'].homepage}  ${USERS.users['${userName}'].browser}  alias=${BROWSER_ALIAS}
  Set Window Size        @{USERS.users['${userName}'].size}
  Set Window Position    @{USERS.users['${userName}'].position}
  Run Keyword If        '${userName}' != 'pag_Viewer'  Login  ${userName}

Login
  [Arguments]  ${userName}
  Wait Until Page Contains Element    id=login-button
  Click Element                       id=login-button
  Wait Until Element Is Visible       id=login-form-login   30
  Input text                          xpath=//input[contains(@id, 'login-form-login')]   ${USERS.users['${userName}'].login}
  Input text                          xpath=//input[contains(@id, 'login-form-password')]   ${USERS.users['${userName}'].password}
  Click Element                       id=login-form-button
  Wait Until Page Contains Element    css=.logout   45

Створити тендер
  [Arguments]   ${userName}   ${auction_data}
  ${procurementMethodType}=        Get From Dictionary   ${auction_data.data}   procurementMethodType
  ${tenderAttempts}=               Get From Dictionary   ${auction_data.data}   tenderAttempts
  ${title}=                        Get From Dictionary   ${auction_data.data}   title
  ${description}=                  Get From Dictionary   ${auction_data.data}   description
  ${dgfID}=                        Get From Dictionary   ${auction_data.data}   dgfID
  ${valueAmount}=                  Get From Dictionary   ${auction_data.data.value}   amount
  ${valueAddedTaxIncluded}=        Get From Dictionary   ${auction_data.data.value}   valueAddedTaxIncluded
  ${minimalStepAmount}=            Get From Dictionary   ${auction_data.data.minimalStep}   amount
  ${guaranteeAmount}=              Get From Dictionary   ${auction_data.data.guarantee}   amount

  ${nameContactPoint}=             Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   name
  ${emailContactPoint}=            Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   email
  ${faxNumberContactPoint}=        Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   faxNumber
  ${telephoneContactPoint}=        Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   telephone
  ${urlContactPoint}=              Get From Dictionary    ${auction_data.data.procuringEntity.contactPoint}   url

  ${procurementMethodType}=        cdb_format_to_view_format   ${procurementMethodType}
  ${tenderAttempts}=               Convert To String    ${tenderAttempts}
  ${tenderAttempts}=               cdb_format_to_view_format   ${tenderAttempts}
  ${valueAmount} =                 Convert To String   ${valueAmount}
  ${valueAddedTaxIncluded}         Convert To String   ${valueAddedTaxIncluded}
  ${valueAddedTaxIncluded}         Convert To Lowercase   ${valueAddedTaxIncluded}
  ${minimalStepAmount}=            Convert To String   ${minimalStepAmount}
  ${guaranteeAmount}=              Convert To String   ${guaranteeAmount}


  ${auctionPeriodStartDate}=       convert_iso_to_format  ${auction_data.data.auctionPeriod.startDate}  %Y-%m-%d %H:%M

  Wait Until Element Is Visible   id=add_tender
  Click Element                   id=add_tender
  Sleep                           1
  Click Element                   xpath=//a[contains(@href, 'procurementMethodType=${auction_data.data.procurementMethodType}')]
  Wait Until Element Is Visible   id=auction-title

  SelectBox                        auction-tenderattempts   ${tenderAttempts}
  Input Text                       id=auction-title    ${title}
  Input Text                       id=auction-description    ${description}
  Input Text                       id=auction-dgfid    ${dgfID}
  Input Text                       id=auction-dgfdecisionid  ${auction_data.data.dgfDecisionID}
  Execute JavaScript               $('#auction-dgfdecisiondate').removeAttr('readonly');
  Input Text                       id=auction-dgfdecisiondate   ${auction_data.data.dgfDecisionDate}
  Input Text                       id=Auction-value-amount   ${valueAmount}
  SwitchBox                        Auction-value-valueAddedTaxIncluded   ${valueAddedTaxIncluded}
  Input Text                       id=Auction-minimalStep-amount   ${minimalStepAmount}
  Input Text                       id=Auction-guarantee-amount   ${guaranteeAmount}

  Execute Javascript               $('#auction-auctionperiod-startdate').val('${auctionPeriodStartDate}');

  Input Text                       id=contactPerson-name   ${nameContactPoint}
  Input Text                       id=contactPerson-telephone   ${telephoneContactPoint}
  Input Text                       id=contactPerson-faxNumber   ${faxNumberContactPoint}
  Input Text                       id=contactPerson-email   ${emailContactPoint}
  Input Text                       id=contactPerson-url   ${urlContactPoint}

  В кінець сторінки

  Click Element  xpath=//div[contains(@class, 'tender-form')]//button[@type='submit']

  ${items}=  Get From Dictionary  ${auction_data.data}  items

  Додати активи  ${items}
  Click Element  id=endEdit

  Wait Until Element Is Visible  xpath=//h1[text()='Чернетки']

  Дія з аукціоном-чернеткою  ${dgfID}  draft-publication

  Wait Until Keyword Succeeds   4 x   20 s   Run Keywords
  ...  Reload Page
  ...  AND  Page Should Not Contain  ${title}

  Перейти в розділ продаю

  Wait Until Element Is Visible   xpath=//a[contains(., '${title}')]
  Click Element                   xpath=//a[contains(., '${title}')]

  Wait Until Element Is Visible  css=.auction-auctionID

  Run Keyword And Return  Get Text  css=.auction-auctionID

Додати актив
  [Arguments]  ${item}
  ${quantity}=  Convert To String  ${item.quantity}

  Input Text  id=item-description  ${item.description}
  Input Text  id=item-quantity     ${quantity}
  SelectBox   item-unitid          ${item.unit.name}

  Обрати класифікатор  classification-container-w1  ${item.classification}

  Click Element                   xpath=//div[contains(@class, 'tender-form')]//button[@type='submit']
  Wait Until Element Is Visible   id=endEdit  30

На форму додавання активу
  ${addItem}=   Run Keyword And Return Status   Page Should Contain Element   xpath=//a[contains(text(), 'Додати актив')]
  Run Keyword If   ${addItem}   Click Element   xpath=//a[contains(text(), 'Додати актив')]
  Wait Until Element Is Visible   id=item-description   15

Додати активи
  [Arguments]   ${items}
  ${count}=   Get Length   ${items}
  : FOR    ${index}    IN RANGE   ${count}
  \   На форму додавання активу
  \   Додати актив   ${items[${index}]}

Пошук тендера по ідентифікатору
  [Arguments]  ${userName}  ${auctionId}
  Switch Browser   ${BROWSER_ALIAS}

  Run Keyword And Ignore Error  Очиcтити фільтр

  Wait Until Element Is Visible  id=main-auctionsearch-title
  На початок сторінки

  Wait Until Keyword Succeeds  10 x   30 s  Run Keywords
  ...       Element Should Be Visible   id=main-auctionsearch-title
  ...  AND  Input Text                  id=main-auctionsearch-title  ${auctionId}
  ...  AND  Click Element               id=search-main
  ...  AND  Element Should Be Visible   xpath=//div[contains(@class, 'one_card')]//a[@href='/auctions/auction/${auctionId}']

  Sleep  1
  Click Element  xpath=//div[contains(@class, 'one_card')]//a[@href='/auctions/auction/${auctionId}']//div[contains(@class, 'lot_image')]

  Wait Until Element Is Visible  css=.auction-auctionID

На початок сторінки
  Execute JavaScript  $(window).scrollTop(0);
  Sleep               1

В кінець сторінки
  Execute JavaScript  window.scrollTo(0, document.body.scrollHeight);
  Sleep               1

Scroll Page To Element
  [Arguments]  ${locator}
  ${jsSelector}=  Run Keyword If  'css' in '${locator}'  Replace String  ${locator}  css=  ${EMPTY}  count=1
  ...  ELSE  Replace String  ${locator}  id=  \#  count=1

  Execute Javascript  window.$('${jsSelector}')[0].scrollIntoView();
  Sleep  2s

Пошук тендера у разі наявності змін
  [Arguments]   ${last_mod_date}   ${userName}   ${auctionId}
  ${status}=   Run Keyword And Return Status   Should Not Be Equal   ${MODIFICATION_DATE}   ${last_mod_date}
  Run Keyword If   ${status}   pag.Пошук тендера по ідентифікатору   ${userName}   ${auctionId}
  Set Global Variable   ${MODIFICATION_DATE}   ${last_mod_date}
  Run Keyword And Ignore Error   На початок сторінки
  Run Keyword And Ignore Error   Click Link   css=.auction-reload

Завантажити документ в тендер з типом
  [Arguments]   ${userName}   ${auctionId}   ${filePath}   ${document_type}=${EMPTY}
  Перейти в розділ продаю
  Дія з аукціоном  ${auctionId}  auction-documents

  Wait Until Page Contains Element   id=documents-box-auctionDocuments   30
  Розгорнути блоки
  Sleep                              2
  Click Element                      xpath=//*[@id='addDocument-w0-auctionDocuments']
  Sleep                              2
  ${lastDocumentRowId}=                     Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Choose File                        xpath=//div[@id='${lastDocumentRowId}']//input[@class='document-img']   ${filePath}
  Wait Until Page Contains           Done    30
  Run Keyword If                     '${document_type}' != '${EMPTY}'   Select From List By Value   xpath=//div[@id='${lastDocumentRowId}']//select  ${document_type}
  Click Element                      xpath=//button[contains(text(), 'Заватажити')]

Отримати кількість предметів в тендері
  [Arguments]  ${userName}  ${auctionId}
  pag.Пошук тендера по ідентифікатору  ${userName}  ${auctionId}
  Таб Активи аукціону

  ${countItems}=  Get Matching Xpath Count  //div[@id='items']//li
  [return]  ${countItems}

Завантажити документ
  [Arguments]  ${userName}   ${filePath}   ${auctionId}
  pag.Завантажити документ в тендер з типом   ${userName}   ${auctionId}   ${filePath}
Змінити документ в ставці
  [Arguments]   ${userName}   ${auctionId}    ${path}   ${docid}
  Fail    Після відправки заявки оператору майданчика  - змінити доки неможливо

Прикріпити документ до цінової пропозиції
  ${filePath}  ${file_name}  ${file_content}=  create_fake_doc
  Завантажити один документ  ${filePath}

Чи фінансова процедура
  ${result}=  Run Keyword And Return Status
  ...  Element Should Be Visible  xpath=//span[contains(text(), 'Право вимоги') or contains(text(), 'Права вимоги')]
  Set Global Variable  ${isFinancial}  ${result}

Подати цінову пропозицію
  [Arguments]  ${userName}  ${auctionId}  ${bidData}

  Run Keyword And Return If  ${bidData.data.qualified} == ${False}  Fail  Учасник не кваліфікований

  pag.Пошук тендера по ідентифікатору  ${userName}  ${auctionId}

  Run Keyword If  ${isFinancial} is ${None}  Чи фінансова процедура

  Click Element                  css=.auction-bid-create
  Wait Until Element Is Visible  id=bid-condition1

  ${isExistValue}=    Run Keyword And Return Status   Dictionary Should Contain Key  ${bidData.data}  value
  Run Keyword If      ${isExistValue}  Ввести цінову пропозицію  ${bidData.data.value.amount}
  Run Keyword If      ${isFinancial}   Прикріпити документ до цінової пропозиції

  Execute JavaScript  $('input[id*=bid-condition]').trigger('click');
  Sleep               1
  Click Element       xpath=//button[text()='Зберегти як чернетку']


  Wait Until Element Is Visible  xpath=//div[contains(@class, 'one_card')]//span[text()='${auctionId}']

  Run Keyword Unless  ${isFinancial}     Дія з пропозицією  ${auctionId}  bid-publication
  Run Keyword Unless  ${isExistValue}    Дія з пропозицією  ${auctionId}  bid-publication

Ввести цінову пропозицію
  [Arguments]  ${value}
  ${value}=   Convert To String    ${value}
  Input text  id=Bid-value-amount  ${value}

Дія з пропозицією
  [Arguments]  ${auctionId}  ${htmlAttributeClass}
  Execute Javascript  $('span:contains("${auctionId}")').closest('.one_card').find('.fa-angle-down').click();
  Sleep               1
  Execute Javascript  $(location).attr('href', $('span:contains("${auctionId}")').closest('.one_card').find('.${htmlAttributeClass}').attr('href'));

Завантажити фінансову ліцензію
  [Arguments]  ${userName}  ${auctionId}  ${filePath}

  Return From Keyword If  'Можливість завантажити фінансову ліцензію' in '${TEST_NAME}'  ${True}

  Перейти в розділ купую

  Дія з пропозицією  ${auctionId}  bid-edit

  Wait Until Element Is Visible  id=bid-condition1
  Завантажити один документ      ${filePath}
  Click Element                  xpath=//button[text()='Зберегти як чернетку']

  Wait Until Element Is Visible  xpath=//div[contains(@class, 'one_card')]//span[text()='${auctionId}']

  Дія з пропозицією  ${auctionId}  bid-publication

Завантажити документ в ставку
  [Arguments]  ${userName}  ${filePath}  ${auctionId}
  pag.Пошук тендера по ідентифікатору   ${userName}   ${auctionId}
  Перейти в розділ купую
  Дія з пропозицією  ${auctionId}  bid-edit

  Wait Until Page contains        ПОДАЧА ЦІНОВОЇ ПРОПОЗИЦІЇ   45
  Click Element                   xpath=//button[contains(text(), 'Зберегти')]
  Wait Until Element Is Visible   xpath=//p[contains(text(), 'Купую')]

Перейти в розділ всі аукціони
  На початок сторінки

  ${isAuthorized}=  Run Keyword And Return Status
  ...  Element Should Be Visible  css=.logout

  Return From Keyword If  ${isAuthorized} == ${False}  ${True}

  ${isCurrentPage}=  Run Keyword And Return Status
  ...  Element Should Be Visible  xpath=//h1[text()='Всі аукціони']

  Return From Keyword If  ${isCurrentPage}  ${True}

  Click Element                  id=category-select
  Sleep                          1
  Click Element                  xpath=//ul[@class='dropdown-menu']//a[@href='/auctions-all']
  Wait Until Element Is Visible  xpath=//h1[text()='Всі аукціони']

Перейти в розділ купую
  На початок сторінки
  Click Element                  id=category-select
  Sleep                          1
  Click Element                  xpath=//ul[@class='dropdown-menu']//a[@href='/auctions-all/buy']
  Wait Until Element Is Visible  xpath=//h1[text()='Купую']

Перейти в розділ продаю
  На початок сторінки
  Click Element                   id=category-select
  Sleep                           1
  Click Element                   xpath=//ul[@class='dropdown-menu']//a[@href='/auctions-all/sell']
  Wait Until Element Is Visible   xpath=//h1[text()='Продаю']

Дія з аукціоном-чернеткою
  [Arguments]  ${dgfId}  ${htmlAttributeClass}
  ${dataKey}=   Execute Javascript  return $('span:contains("${dgfId}")').closest('.one_card').parent().attr('data-key');
  Sleep         1
  Scroll Page To Element  css=.tender_list div[data-key="${dataKey}"]

  Execute Javascript  $('span:contains("${dgfId}")').closest('.one_card').find('.fa-angle-down').click();
  Sleep               1
  Execute Javascript  $(location).attr('href', $('span:contains("${dgfId}")').closest('.one_card').find('.${htmlAttributeClass}').attr('href'));

Дія з аукціоном
  [Arguments]  ${auctionId}  ${htmlAttributeClass}
  ${dataKey}=   Execute Javascript  return $('span:contains("${auctionId}")').closest('.one_card').parent().attr('data-key');
  Sleep         1
  Scroll Page To Element  css=.tender_list div[data-key="${dataKey}"]

  Execute Javascript  $('span:contains("${auctionId}")').closest('.one_card').find('.fa-angle-down').click();
  Sleep               1
  Execute Javascript  $(location).attr('href', $('span:contains("${auctionID}")').closest('.one_card').find('.${htmlAttributeClass}').attr('href'));

Скасувати цінову пропозицію
  [Arguments]  ${userName}  ${auctionId}
  pag.Пошук тендера по ідентифікатору  ${userName}  ${auctionId}
  Перейти в розділ купую
  Дія з пропозицією  ${auctionId}  bid-cancellation

Отримати інформацію із пропозиції
  [Arguments]   ${userName}   ${auctionId}   ${field}
  pag.Пошук тендера по ідентифікатору       ${userName}   ${auctionId}
  Перейти в розділ купую
  ${bidValueAmount}=         Get Text   css=.bid-value-amount
  ${bidValueAmount}=         Evaluate   "".join("${bidValueAmount}".replace(",",".").split(' '))
  ${bidValueAmount}=         Convert To Number   ${bidValueAmount}
  [return]                   ${bidValueAmount}

Закрити модальне вікно
  Execute JavaScript   $('.close').trigger('click');
  Sleep    1

Змінити цінову пропозицію
  [Arguments]   ${userName}  ${auctionId}  ${fieldName}  ${fieldValue}
  pag.Пошук тендера по ідентифікатору  ${userName}   ${auctionId}

  Click Element                   css=.bid-change-value-amount
  Sleep                           2

  Wait Until Element Is Visible   id=BidChangeValueAmount-value-amount
  ${value}=                       Convert To String  ${fieldValue}
  Input Text                      id=BidChangeValueAmount-value-amount  ${value}

  Click Element                   xpath=//div[@id='inform_data']//button[@type='submit']
  Wait Until Element Is Visible   xpath=//p[text()='Пропозиція успішно оновлена']

  Закрити модальне вікно

Оновити сторінку з тендером
  [Arguments]  ${userName}  ${auctionId}
  Switch Browser   ${BROWSER_ALIAS}

  Перейти в розділ всі аукціони
  pag.Пошук тендера по ідентифікатору  ${userName}  ${auctionId}

  ${isVisibleReloadButton}=  Run Keyword And Return Status
  ...  Element Should Be Visible  css=.auction-reload

  Run Keyword If  ${isVisibleReloadButton}  Click Element  css=.auction-reload
  ...  ELSE  Reload Page

  Wait Until Element Is Visible  css=.auction-procuringEntity-name

Задати запитання на тендер
  [Arguments]   ${userName}   ${auctionId}   ${question_data}
  ${title}=                       Get From Dictionary  ${question_data.data}  title
  ${description}=                 Get From Dictionary  ${question_data.data}  description
  pag.Пошук тендера по ідентифікатору            ${userName}   ${auctionId}
  Wait Until Element Is Visible   css=.auction-question-create
  Click Link                      css=.auction-question-create
  Wait Until Element Is Visible   id=question-title   30
  ${auctionTitle}=                Get Text    xpath=//a[contains(@class, 'text-justify')]
  SelectBox                       question-element   ${auctionTitle}
  Input text                      id=question-title   ${title}
  Input text                      id=question-description   ${description}
  Click Element                   xpath=//button[contains(text(), 'Запитати')]
  Wait Until Page Contains        Параметри аукціону   45

Задати запитання на предмет
  [Arguments]   ${userName}   ${auctionId}   ${item_id}   ${question_data}
  ${title}=                       Get From Dictionary  ${question_data.data}  title
  ${description}=                 Get From Dictionary  ${question_data.data}  description
  pag.Пошук тендера по ідентифікатору            ${userName}   ${auctionId}
  Wait Until Element Is Visible   css=.auction-question-create
  Click Link                      css=.auction-question-create
  Wait Until Element Is Visible   id=question-title   30
  Execute JavaScript              $("#question-element").val($("#question-element :contains('${item_id}')").last().attr("value")).change();
  Input text                      id=question-title   ${title}
  Input text                      id=question-description   ${description}
  Click Element                   xpath=//button[contains(text(), 'Запитати')]
  Wait Until Page Contains        Параметри аукціону   45

Відповісти на запитання
  [Arguments]   ${userName}   ${auctionId}  ${answer_data}   ${question_id}
  pag.Пошук тендера по ідентифікатору            ${userName}   ${auctionId}
  Таб Запитання
  ${answer}=                      Get From Dictionary  ${answer_data.data}   answer
  Wait Until Page Contains        ${question_id}
  Click Element                   xpath=//div[contains(@data-question-title, '${question_id}')]//a[contains(@class, 'question-answer')]
  Wait Until Element Is Visible   id=question-answer
  Input Text                      id=question-answer   ${answer}
  Click Element                   xpath=//button[contains(text(), 'Надати відповідь')]
  Wait Until Page Contains        Параметри аукціону   45

Отримати інформацію із тендера
  [Arguments]   ${userName}   ${auctionId}   ${field}
  pag.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${userName}   ${auctionId}

  Run Keyword And Return If  '${field}' == 'awards[0].status'  Отримати інформацію про статус аворду  0
  Run Keyword And Return If  '${field}' == 'awards[1].status'  Отримати інформацію про статус аворду  1

  Run Keyword And Return If  '${field}' == 'contracts[0].status'  Отримати інформацію про статус договору  0
  Run Keyword And Return If  '${field}' == 'contracts[1].status'  Отримати інформацію про статус договору  1

  Run Keyword And Return   Отримати інформацію про ${field}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${field}
  Wait Until Page Contains Element   ${locator.${field}}    30
  ${value}=                          Get Text   ${locator.${field}}
  [return]                           ${value}

Отримати інформацію про status
  Reload Page
  ${status}=   Отримати текст із поля і показати на сторінці   status
  ${status}=   view_to_cdb_fromat   ${status}
  [return]     ${status}

Отримати інформацію про dgfDecisionID
  Таб Параметри аукціону
  ${dgfDecisionID}=   Отримати текст із поля і показати на сторінці   dgfDecisionID
  [return]            ${dgfDecisionID}

Отримати інформацію про dgfDecisionDate
  Таб Параметри аукціону
  ${dgfDecisionDate}=   Отримати текст із поля і показати на сторінці   dgfDecisionDate
  ${dgfDecisionDate}=   convert_date_to_dash_format   ${dgfDecisionDate}
  [return]              ${dgfDecisionDate}

Отримати інформацію про eligibilityCriteria
  ${return_value}=   Отримати текст із поля і показати на сторінці   eligibilityCriteria
  [return]           ${return_value}

Отримати інформацію про procurementMethodType
  ${procurementMethodType}=   Отримати текст із поля і показати на сторінці   procurementMethodType
  ${procurementMethodType}=   view_to_cdb_fromat   ${procurementMethodType}
  [return]                    ${procurementMethodType}

Отримати інформацію про dgfID
  Таб Параметри аукціону
  ${dgfID}=   Отримати текст із поля і показати на сторінці   dgfID
  [return]    ${dgfID}

Отримати інформацію про title
  ${title}=   Отримати текст із поля і показати на сторінці   title
  ${title}=   Replace String   ${title}   &#039;   '
  [return]    ${title}

Отримати інформацію про description
  ${description}=   Отримати текст із поля і показати на сторінці   description
  ${description}=   Replace String   ${description}   &#039;   '
  [return]          ${description}

Отримати інформацію про minimalStep.amount
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про розмір ставки
  ${return_value}=   Отримати текст із поля і показати на сторінці   mybid
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про value.amount
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про guarantee.amount
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  guarantee.amount
  ${return_value}=   Evaluate   "".join("${return_value}".replace(",",".").split(' '))
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про auctionID
  ${auctionID}=   Отримати текст із поля і показати на сторінці   auctionID
  [return]        ${auctionID}

Отримати інформацію про value.currency
  Таб Параметри аукціону
  ${currency}=   Отримати текст із поля і показати на сторінці   value.currency
  ${currency}=   view_to_cdb_fromat   ${currency}
  [return]       ${currency}

Отримати інформацію про value.valueAddedTaxIncluded
  Таб Параметри аукціону
  ${tax}=    Отримати текст із поля і показати на сторінці   value.valueAddedTaxIncluded
  ${tax}=    view_to_cdb_fromat   ${tax}
  ${tax}=    Convert To Boolean   ${tax}
  [return]   ${tax}

Отримати інформацію про procuringEntity.name
  ${procuringEntityName}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]                  ${procuringEntityName}

Отримати інформацію про tenderAttempts
  Таб Параметри аукціону
  ${tenderAttempts}=   Отримати текст із поля і показати на сторінці   tenderAttempts
  ${tenderAttempts}=   view_to_cdb_fromat   ${tenderAttempts}
  [return]             ${tenderAttempts}

Отримати інформацію про auctionPeriod.startDate
  Таб Параметри аукціону
  ${startDate}=   Отримати текст із поля і показати на сторінці    auctionPeriod.startDate
  ${startDate}=   subtract_from_time   ${startDate}  0  0
  [return]        ${startDate}

Отримати інформацію про auctionPeriod.endDate
  Таб Параметри аукціону
  Wait Until Keyword Succeeds   20 x   40 s   Run Keywords
  ...   Reload Page
  ...   AND   Таб Параметри аукціону
  ...   AND   Element Should Be Visible   css=.auction-period-end
  ${endDate}=   Отримати текст із поля і показати на сторінці   auctionPeriod.endDate
  ${endDate}=   subtract_from_time   ${endDate}  0  0
  [return]      ${endDate}

Отримати інформацію про tenderPeriod.startDate
  Таб Параметри аукціону
  ${startDate}=   Отримати текст із поля і показати на сторінці  tenderPeriod.startDate
  ${startDate}=   subtract_from_time    ${startDate}  0  0
  [return]        ${startDate}

Отримати інформацію про tenderPeriod.endDate
  Таб Параметри аукціону
  ${endDate}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${endDate}=   subtract_from_time   ${endDate}  0  0
  [return]      ${endDate}

Отримати інформацію про qualificationPeriod.startDate
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.startDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]           ${return_value}

Отримати інформацію про qualificationPeriod.endDate
  Таб Параметри аукціону
  ${return_value}=   Отримати текст із поля і показати на сторінці  qualificationPeriod.endDate
  ${return_value}=   subtract_from_time   ${return_value}  0  0
  [return]           ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  Fail  enquiryPeriod відсутній

Отримати інформацію про enquiryPeriod.endDate
  Fail  enquiryPeriod відсутній

Отримати інформацію із предмету
  [Arguments]   ${userName}   ${auctionId}   ${item_id}   ${field}
  На початок сторінки
  Скролл до табів
  Таб Активи аукціону
  Wait Until Element Is Visible   xpath=//a[contains(text(), '${item_id}')]
  Click Link                      xpath=//a[contains(text(), '${item_id}')]
  Wait Until Element Is Visible   xpath=//div[contains(@data-item-description, '${item_id}')]
  ${fieldValue}=                  Get Text   xpath=//div[contains(@data-item-description, '${item_id}')]//*[contains(@class, 'item-${field.replace('.','-').replace('code','name')}')]
  ${fieldValue}=                  adapt_items_data   ${field}   ${fieldValue}
  [return]                        ${fieldValue}

Отримати посилання на аукціон для глядача
  [Arguments]   ${userName}   ${auctionId}   ${lot_id}=${Empty}
  Run Keyword And Return   Отримати посилання на аукціон   ${userName}   ${auctionId}   auction-url

Отримати посилання на аукціон для учасника
  [Arguments]   ${userName}   ${auctionId}   ${lot_id}=${Empty}
  Run Keyword And Return   Отримати посилання на аукціон   ${userName}   ${auctionId}   bidder-url

Отримати посилання на аукціон
  [Arguments]   ${userName}   ${auctionId}   ${auctionOrBidderUrl}
  pag.Пошук тендера по ідентифікатору   ${userName}   ${auctionId}
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Element Should Be Visible   css=.${auctionOrBidderUrl}
  Run Keyword And Return    Get Element Attribute   css=.${auctionOrBidderUrl}@href

Скролл до табів
  Scroll To Element  .nav-tabs-ubiz
  Sleep              1

Завантажити протокол аукціону
  [Arguments]  ${userName}  ${auctionId}  ${filePath}  ${awardNumber}
  pag.Пошук тендера по ідентифікатору  ${userName}  ${auctionId}

  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...  Reload Page
  ...  AND  Таб Кваліфікація

Завантажити ілюстрацію
  [Arguments]   ${userName}   ${auctionId}   ${filePath}
  pag.Завантажити документ в тендер з типом   ${userName}   ${auctionId}   ${filePath}   illustration

Додати публічний паспорт активу
  [Arguments]  ${userName}  ${auctionId}  ${certificateUrl}
  Перейти в розділ продаю
  Дія з аукціоном  ${auctionId}  auction-documents

  Wait Until Element Is Visible  id=documents-box-auctionDocuments   30
  Розгорнути блоки

  Click Element                  xpath=//div[@id='documents-box-auctionDocuments']//button[contains(@class, 'add-item')]
  Wait Until Element Is Visible  css=.delete-document

  ${lastDocumentRowId}=          Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Select From List By Value      xpath=//div[@id='${lastDocumentRowId}']//select   x_dgfPublicAssetCertificate
  Wait Until Element Is Visible  xpath=//div[@id='${lastDocumentRowId}']//textarea[contains(@name, 'textDocument')]   10
  Input text                     xpath=//div[@id='${lastDocumentRowId}']//textarea[contains(@name, 'textDocument')]   ${certificateUrl}
  Click Element                  xpath=//button[text()='Заватажити']

Додати офлайн документ
  [Arguments]  ${userName}  ${auctionId}  ${accessDetails}
  Перейти в розділ продаю
  Дія з аукціоном  ${auctionId}  auction-documents

  Wait Until Page Contains Element      id=documents-box-auctionDocuments   30
  Розгорнути блоки

  Click Element                         id=addDocument-w0-auctionDocuments
  Sleep                                 2
  ${lastDocumentRowId}=                 Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Select From List By Value             xpath=//div[@id='${lastDocumentRowId}']//select    x_dgfAssetFamiliarization
  Wait Until Page Contains Element      xpath=//div[@id='${lastDocumentRowId}']//textarea[contains(@name, 'textDocument')]    10
  Input text                            xpath=//div[@id='${lastDocumentRowId}']//textarea[contains(@name, 'textDocument')]   ${accessDetails}
  Click Element                         xpath=//button[contains(text(), 'Заватажити')]

Отримати інформацію із запитання
  [Arguments]   ${userName}   ${auctionId}   ${question_id}   ${field}
  pag.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${userName}   ${auctionId}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   Таб Запитання
  ...   AND   Page Should Contain   ${question_id}
  ${fieldValue}=    Get Text   xpath=//div[contains(@data-question-title, '${question_id}')]//*[contains(@class, 'question-${field}')]
  [return]          ${fieldValue}

Отримати інформацію із документа по індексу
  [Arguments]  ${userName}  ${auctionId}  ${documentIndex}  ${field}
  pag.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${userName}   ${auctionId}
  Таб Документи
  Wait Until Element Is Visible  xpath=//a[@href='#documents_auction']
  ${text}=                       Get Text   css=.document-documentType
  ${text}=                       view_to_cdb_fromat   ${text}
  [return]                       ${text}

Отримати інформацію із документа
  [Arguments]   ${userName}   ${auctionId}   ${documentId}   ${field}
  pag.Пошук тендера у разі наявності змін   ${TENDER['LAST_MODIFICATION_DATE']}   ${userName}   ${auctionId}
  ${currentStatus}=               Get Text   css=.auction-status
  ${wasCancelled}=                Run Keyword And Return Status   Should Be Equal   ${currentStatus}   СКАСОВАНИЙ
  Run Keyword If   ${wasCancelled}   Таб Скасування
  ...   ELSE    Таб Документи
  ${fieldValue}=                  Get Text   xpath=//div[contains(@data-document-title, '${documentId}')]//*[contains(@class, 'document-${field}')]
  [return]                        ${fieldValue}

Отримати документ
  [Arguments]  ${userName}  ${auctionId}  ${documentId}
  pag.Пошук тендера у разі наявності змін  ${TENDER['LAST_MODIFICATION_DATE']}  ${userName}  ${auctionId}
  Таб Документи
  Wait Until Element Is Visible  xpath=//a[@href='#documents_auction']

  ${fileName}=  Get Text                xpath=//div[contains(@data-document-title, '${documentId}')]//a
  ${fileUrl}=   Get Element Attribute   xpath=//div[contains(@data-document-title, '${documentId}')]//a@href
  ${fileName}=  download_file_from_url  ${fileUrl}  ${OUTPUT_DIR}${/}${fileName}

  [return]  ${fileName}

Розгорнути блоки
  Execute JavaScript   $('.fa-plus').trigger('click');
  Sleep    2

Завантажити один документ
  [Arguments]  ${filePath}
  Scroll Page To Element   css=.box-default

  ${documentBoxIsOpened}=  Run Keyword And Return Status  Element Should Be Visible  css=.add-item
  Run Keyword Unless  ${documentBoxIsOpened}  Click Element  xpath=//h3[@class='box-title']

  Sleep  1

  Wait Until Element Is Visible  css=.add-item
  Click Element                  css=.add-item
  Sleep                          2

  Choose File                    xpath=//div[contains(@class, 'form-documents-item')][last()]//input[@class='document-img']  ${filePath}
  Wait Until Element Is Visible  xpath=//div[contains(., 'Done')]

Скасувати закупівлю
  [Arguments]   ${userName}   ${auctionId}   ${reason}   ${filePath}   ${description}
  pag.Пошук тендера по ідентифікатору               ${userName}   ${auctionId}
  Click Link                         css=.auction-cancellation
  Wait Until Page Contains           Скасування аукціону   45
  Scroll To Element                  .container
  SelectBox                          cancellation-reason   ${reason}
  Завантажити один документ          ${filePath}
  Click Element                      xpath=//button[contains(text(), 'Скасувати')]
  Wait Until Page Contains Element   xpath=//a[@href='#cancellations']   45

Отримати інформацію про статус аворду
  [Arguments]  ${awardNumber}
  Таб Кваліфікація

  ${awardNumber}=  Set Variable If  "Можливість дискваліфікувати першого кандидата" == "${PREV TEST NAME}"  1  ${awardNumber}
  ${awardNumber}=  Set Variable If  "Відображення статусу 'unsuccessful' для першого кандидата" == "${PREV TEST NAME}"  0  ${awardNumber}

  ${awardNumber}=  Set Variable If  "Відображення статусу 'очікується протокол' для другого кандидата" == "${PREV TEST NAME}"  0  ${awardNumber}
  ${awardNumber}=  Set Variable If  "Можливість підтвердити другого кандидата" == "${PREV TEST NAME}"  0  ${awardNumber}

  ${awardStatus}=  Get Text  xpath=//h3[contains(@class, 'award-status-${awardNumber}')]
  ${awardStatus}=  view_to_cdb_fromat  ${awardStatus}

  [return]  ${awardStatus}

Отримати інформацію про статус договору
  [Arguments]  ${contractNumber}
  Таб Контракт

  ${contractStatus}=  Get Text  xpath=(//h3[contains(@class, 'contract-status')])[1]
  ${contractStatus}=  view_to_cdb_fromat  ${contractStatus}

  [return]  ${contractStatus}

Отримати інформацію про cancellations[0].status
  Таб Скасування
  ${return_value}=   Отримати текст із поля і показати на сторінці   cancellations[0].status
  ${return_value}=   view_to_cdb_fromat  ${return_value}
  [return]           ${return_value}

Отримати інформацію про cancellations[0].reason
  Таб Скасування
  ${return_value}=   Отримати текст із поля і показати на сторінці   cancellations[0].reason
  [return]           ${return_value}

Отримати кількість документів в тендері
  [Arguments]   ${userName}   ${auctionId}
  pag.Пошук тендера по ідентифікатору   ${userName}   ${auctionId}
  Таб Документи
  ${countDocuments}=     Get Matching Xpath Count   xpath=//p[contains(@class,'document-datePublished')]
  [return]               ${countDocuments}

Отримати дані із документу пропозиції
  [Arguments]  ${userName}   ${auctionId}   ${bid_index}   ${documentIndex}   ${field}
  ${fileid_index}=   Catenate   SEPARATOR=   ${field}   ${documentIndex}
  ${doc_value}=      Get Text   xpath=//span[contains(@class, '${fileid_index}')]
  ${doc_value}=      view_to_cdb_fromat   ${doc_value}
  [return]           ${doc_value}

Дискваліфікувати постачальника
  [Arguments]  ${userName}  ${auctionId}  ${awardNumber}  ${description}
  pag.Пошук тендера по ідентифікатору   ${userName}   ${auctionId}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...  Reload Page
  ...  AND  Таб Кваліфікація

  Розгорнути блоки
  Wait Until Element Is Visible  css=.award-disqualification
  Click Element                  css=.award-disqualification

  Wait Until Element Is Visible  id=disqualification-title

  Input Text     id=disqualification-title        ${description}
  Input Text     id=disqualification-description  ${description}

  ${hasDocumentsBox}=  Run Keyword And Return Status  Page Should Contain Element  id=documents-box
  Run Keyword If  ${hasDocumentsBox}  Завантажити документ до дискваліфікації

  Click Element  xpath=//button[text()='Дискваліфікувати']

  Wait Until Element Is Visible  xpath=//a[@href='#parameters']  30

Завантажити документ до дискваліфікації
  ${filePath}  ${file_name}  ${file_content}=  create_fake_doc
  Завантажити один документ  ${filePath}

Завантажити угоду до тендера
  [Arguments]  ${userName}  ${auctionId}  ${contractNumber}  ${filePath}
  pag.Пошук тендера по ідентифікатору  ${userName}  ${auctionId}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   Таб Контракт

Підтвердити підписання контракту
  [Arguments]  ${userName}  ${auctionId}  ${contractNumber}
  pag.Пошук тендера по ідентифікатору  ${userName}  ${auctionId}
  Таб Контракт

  Wait Until Element Is Visible  css=.contract-publication
  Click Link                     css=.contract-publication

  Wait Until Element Is Visible  xpath=//button[text()='Опублікувати']

  ${filePath}  ${file_name}  ${file_content}=  create_fake_doc
  Завантажити один документ  ${filePath}

  Click Element                  xpath=//button[text()='Опублікувати']
  Wait Until Element Is Visible  xpath=//a[@href='#parameters']  45

Завантажити протокол аукціону в авард
  [Arguments]   ${userName}   ${auctionId}   ${filePath}   ${awardNumber}
  pag.Пошук тендера по ідентифікатору   ${userName}   ${auctionId}
  Wait Until Keyword Succeeds   10 x   30 s   Run Keywords
  ...   Reload Page
  ...   AND   Таб Кваліфікація
  Wait Until Page Contains Element    css=.award-upload-protocol
  Click Link                          css=.award-upload-protocol
  Wait Until Page Contains            Завантаження протоколу аукціону   30
  Завантажити один документ           ${filePath}
  Scroll To Element                   .action_period

Підтвердити наявність протоколу аукціону
  [Arguments]   ${userName}   ${auctionId}   ${awardNumber}
  Wait Until Page Contains Element   xpath=//button[contains(text(), 'Завантажити')]
  Click Element                      xpath=//button[contains(text(), 'Завантажити')]
  Wait Until Page Contains Element   xpath=//a[@href='#parameters']   45

Підтвердити постачальника
  [Arguments]  ${userName}  ${auctionId}  ${awardNumber}

  Run Keyword If  'Неможливість підтвердити' in '${TEST_NAME}'  Fail  Протокол відсутній

  pag.Пошук тендера по ідентифікатору  ${userName}  ${auctionId}
  Таб Кваліфікація

  Click Element                  css=.award-upload-protocol
  Wait Until Element Is Visible  id=documents-box

  ${filePath}  ${file_name}  ${file_content}=  create_fake_doc
  Завантажити один документ  ${filePath}
  Click Element              xpath=//button[text()='Завантажити']

  Wait Until Element Is Visible  xpath=//a[@href='#parameters']  45

Скасування рішення кваліфікаційної комісії
  [Arguments]   ${userName}   ${auctionId}   ${award_num}
  Перейти в розділ купую
  Wait Until Keyword Succeeds   10 x   15 s   Run Keywords
  ...   Reload Page
  ...   AND   Дія з пропозицією  ${auctionId}  bid-award-cancellation

Таб Параметри аукціону
  Скролл до табів
  Click Link  xpath=//a[@href='#parameters']

Таб Активи аукціону
  Скролл до табів
  Click Link  xpath=//a[@href='#items']

Таб Документи
  Скролл до табів
  Click Link  xpath=//a[@href='#documents']

Таб Запитання
  Скролл до табів
  Click Link  xpath=//a[@href='#questions']

Таб Пропозиції
  Скролл до табів
  Click Link  xpath=//a[@href='#bids']

Таб Кваліфікація
  Скролл до табів
  Click Element  xpath=//a[@href='#awards']
  Розгорнути блоки

Таб Контракт
  Скролл до табів
  Click Link  xpath=//a[@href='#contracts']

Таб Скасування
  Скролл до табів
  Розгорнути блоки
  Click Link  xpath=//a[@href='#cancellations']

SelectBox
  [Arguments]   ${htmlAttributeId}   ${text}
  Execute JavaScript   $("#${htmlAttributeId}").val($("#${htmlAttributeId} :contains('${text}')").first().attr("value")).change();

SwitchBox
  [Arguments]   ${htmlAttributeId}   ${flag}
  Execute JavaScript   $("#${htmlAttributeId}").bootstrapSwitch('state', ${flag}, true).trigger('switchChange.bootstrapSwitch');

Scroll To Element
  [Arguments]   ${selector}
  Execute JavaScript   var targetOffset = $('${selector}').offset().top; $('html, body').animate({scrollTop: targetOffset}, 1000);
  Sleep    2

Змінити ціновий показник
  [Arguments]   ${locator}   ${value}
  ${value}=     Convert To String   ${value}
  Input Text    id=Edit-${locator}   ${value}

Завантажити документ погодження змін до опису аукціону
   ${filePath}  ${file_name}  ${file_content}=  create_fake_doc
   Завантажити один документ  ${filePath}
   Click Element              xpath=//button[text()='Заватажити']

   Wait Until Element Is Visible  xpath=//input[@id='edit-title']

Внести зміни в тендер
  [Arguments]  ${userName}  ${auctionId}  ${field}  ${value}
  Перейти в розділ продаю
  Дія з аукціоном  ${auctionId}  auction-edit

  ${isUploadedClarificationDocument}=  Run Keyword And Return Status
  ...  Element Should Be Visible   css=.add-item
  Run Keyword If  ${isUploadedClarificationDocument}  Завантажити документ погодження змін до опису аукціону

  Run Keyword  Змінити ${field} аукціону  ${value}

  Click Element                   xpath=//button[text()='Оновити']
  Sleep                           1
  Wait Until Element Is Visible   xpath=//h1[text()='Продаю']  30

  Перейти в розділ всі аукціони

Змінити tenderattempts аукціону
  [Arguments]  ${value}
  ${value}=  Convert To String          ${value}
  ${value}=  cdb_format_to_view_format  ${value}
  SelectBox  edit-tenderattempts        ${value}

Змінити title аукціону
  [Arguments]  ${value}
  Input Text  id=edit-title  ${value}

Змінити description аукціону
  [Arguments]  ${value}
  Input Text  id=edit-description  ${value}

Змінити dgfID аукціону
  [Arguments]  ${value}
  Input Text  id=edit-dgfid  ${value}

Змінити dgfDecisionID аукціону
  [Arguments]  ${value}
  Input Text  id=edit-dgfdecisionid  ${value}

Змінити dgfDecisionDate аукціону
  [Arguments]  ${value}
  Input Text  id=edit-dgfdecisiondate  ${value}

Змінити minimalStep.amount аукціону
  [Arguments]  ${value}
  ${value}=   Convert To String           ${value}
  Input Text  id=Edit-minimalStep-amount  ${value}

Змінити guarantee.amount аукціону
  [Arguments]  ${value}
  ${value}=   Convert To String         ${value}
  Input Text  id=Edit-guarantee-amount  ${value}

Додати Virtual Data Room
  [Arguments]  ${userName}  ${auctionId}  ${vdrLink}
  Перейти в розділ продаю
  Дія з аукціоном  ${auctionId}  auction-documents

  Wait Until Page Contains Element  id=documents-box-auctionDocuments   30
  Розгорнути блоки

  Click Element                     id=addDocument-w0-auctionDocuments
  Sleep                             2
  ${lastDocumentRowId}=             Execute JavaScript   return $('#documents-list-w0-auctionDocuments').find('.form-documents-item').last().attr('id');
  Select From List By Value         xpath=//div[@id='${lastDocumentRowId}']//select    virtualDataRoom
  Wait Until Page Contains Element  xpath=//div[@id='${lastDocumentRowId}']//textarea[contains(@name, 'textDocument')]
  Input text                        xpath=//div[@id='${lastDocumentRowId}']//textarea[contains(@name, 'textDocument')]  ${vdrLink}
  Click Element                     xpath=//button[text()='Заватажити']

Додати предмет закупівлі
  [Arguments]  ${userName}  ${auctionId}  ${item}
  Перейти в розділ продаю

Видалити предмет закупівлі
  [Arguments]  ${userName}  ${auctionId}  ${item_id}  ${lot_id}=${EMPTY}
  FAIL  неможливо видалити предмет

Очиcтити фільтр
  Click Element  xpath=//a[text()='Очистити фільтр']

Обрати класифікатор
  [Arguments]  ${boxDivId}  ${classification}  ${divIndex}=0

  Execute Javascript  $($('#${boxDivId} div[data-index="${divIndex}"]').first().find('input[type="hidden"]')[0]).val('${classification.id}');
  Execute Javascript  $($('#${boxDivId} div[data-index="${divIndex}"]').first().find('input[type="hidden"]')[1]).val('${classification.description}');
  Execute Javascript  $($('#${boxDivId} div[data-index="${divIndex}"]').first().find('input[type="hidden"]')[2]).val('${classification.scheme}');

  Sleep               2

Отримати інформацію про auctionParameters.dutchSteps
  Таб Параметри аукціону
  ${dutchSteps}=  Get Text  css=.auction-dutchSteps
  ${dutchSteps}=  Convert To Integer  ${dutchSteps}
  [return]        ${dutchSteps}

Отримати інформацію про contracts[1].datePaid
  Таб Контракт
  ${datePaid}=  Get Text  css=.datePaid
  ${datePaid}=  subtract_from_time   ${datePaid}  0  0
  [return]      ${datePaid}
