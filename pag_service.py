# -*- coding: utf-8 -
from iso8601 import parse_date
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime, timedelta
from pytz import timezone
import os
import urllib
import pytz


def get_library():
    return BuiltIn().get_library_instance('Selenium2Library')

def convert_date_to_dash_format(date):
    return datetime.strptime(date,'%d.%m.%Y').strftime('%Y-%m-%d')

def get_webdriver_instance():
    return get_library()._current_browser()

def adapt_items_data(field_name, value):
    if field_name == 'quantity':
        value = float(value)
    elif field_name == "unit.code":
        value = view_to_cdb_fromat(value)
    elif field_name == "contractPeriod.startDate":
        value = toISO(value)
    elif field_name == "contractPeriod.endDate":
        value = toISO(value)
    return value

def toISO(v_date):
    time_zone = pytz.timezone('Europe/Kiev')
    d_date = datetime.strptime(v_date, '%d.%m.%Y')
    localized_date = time_zone.localize(d_date)
    return localized_date.isoformat()

def cdb_format_to_view_format(string):
    return {
        u"dgfFinancialAssets": u"Право вимоги",
        u"dgfOtherAssets": u"Майно банку",
        u"0": u"Невідомо",
        u"1": u'Вперше',
        u"2": u'Вдруге',
        u"3": u'Втретє',
        u"4": u'Вчетверте',
        u"5": u"яте",
        u"6": u"Вшосте",
        u"7": u"Всьоме",
        u"8": u"Ввосьме",
        u"CPV": u"ДК021",
    }.get(string, string)

def view_to_cdb_fromat(string):
    return {
            u"пар": u"PR" ,
            u"літр" : u"LTR",
            u"набір" : u"SET",
            u"пачка" : u"RM",
            u"упаковка" :u"PK",
            u"пачок" : u"NMP",
            u"метри" : u"MTR",
            u"ящик" : u"BX",
            u"метри кубічні" : u"MTQ",
            u"рейс" : u"E54",
            u"тони" : u"TNE",
            u"метри квадратні" : u"MTK",
            u"кілометри" : u"KMT",
            u"штуки" : u"H87",
            u"місяць" : u"MON",
            u"лот" : u"LO",
            u"блок" : u"D64",
            u"гектар" : u"HAR",
            u"кілограми" : u"KGM",
            u"кілограми": u"кілограм",
            u"кг.": u"кілограми",
            u"кг": u"кілограми",
            u"MTK":u"метри квадратні",
            u"Право вимоги": u"dgfFinancialAssets",
            u"Майно банку": u"dgfOtherAssets",
            u"Голландський аукціон": u"dgfInsider",
            u"грн.": u"UAH",
            u"грн": u"UAH",
            u" з ПДВ": True,
            u"послуга":"E48",
            u"Картонки": u"Картонні коробки",
            u"ПЕРІОД ПРОПОЗИЦІЙ": u"active.tendering",
            u"ПЕРІОД АУКЦІОНУ": u"active.auction",
            u"ПРОПОЗИЦІЇ РОЗГЛЯНУТО": u"active.awarded",
            u"ПЕРІОД КВАЛІФІКАЦІЇ": u"active.qualification",
            u"ЗАВЕРШЕНИЙ": u"complete",
            u"СКАСОВАНИЙ": u"cancelled",
            u"Аукціон скасовано" : u"active",
            u"НЕ ВІДБУВСЯ" : u"unsuccessful",
            u"Ліцензія" : u"financialLicense",
            u"Підписаний протокол" : u"auctionProtocol",
            u" - " : u"",
            u"Невідомо": u"",
            u'Вперше':1,
            u'Вдруге':2,
            u'Втретє':3,
            u'Вчетверте':4,
            u"Вп'яте":5,
            u"Вшосте":6,
            u"Всьоме":7,
            u"Ввосьме":8,
            u"Повідомлення про аукціон" : "notice",
            u"Документи аукціону" : u"biddingDocuments",
            u"Публічний паспорт активу" : u"technicalSpecifications",
            u"Критерії оцінки" : u"evaluationCriteria",
            u"Критерії прийнятності" : u"eligibilityCriteria",
            u"Публічний паспорт торгів" : u"virtualDataRoom",
            u"Ілюстрація" : u"illustration",
            u"Посилання на публічний паспорт активу" : u"x_dgfPublicAssetCertificate",
            u"Презентація" : u"x_presentation",
            u"Договір про нерозголошення(NDA)" : u"x_nda",
            u"Паспорт торгів" : u"tenderNotice",
            u"Юридична Інформація Майданчиків" : u"x_dgfPlatformLegalDetails",
            u'Порядку ознайомлення з активом у кімнаті даних' : u'x_dgfAssetFamiliarization',
            u"Порядку ознайомлення з майном" : u'x_dgfAssetFamiliarization',
            u"Очікується кінець кваліфікації" : u"pending.waiting",
            u"Очікується протокол" : u"pending.verification",
            u"Очікується оплата" : u"active",
            u"Кандидат забрав гарантійний внесок" : u"cancelled",
            u"Аукціон неуспішний" : u"unsuccessful",
            u"Оплачено, очікується підписання договору" : u"active",
            u"Скасування активоване": u'active',
            u"Розглядається": u"pending",
            u"Підписаний": u"active",
            u"Скасовано до підписання": u"cancelled",
    }.get(string, string)

def subtract_from_time(date_time, subtr_min, subtr_sec):
    sub = datetime.strptime(date_time, "%d.%m.%Y %H:%M")
    sub = (sub - timedelta(minutes=int(subtr_min),
                           seconds=int(subtr_sec)))
    return timezone('Europe/Kiev').localize(sub).strftime('%Y-%m-%dT%H:%M:%S.%f%z')

def prepare_auction(auctionData, roleName):
    if roleName == 'tender_owner':
        auctionData.data.procuringEntity['name']                      = u"ТОВ 4k-soft"
        auctionData.data.procuringEntity['contactPoint']['telephone'] = u"0993698510"
        auctionData.data.procuringEntity['contactPoint']['faxNumber'] = u"0993698511"

    return auctionData

def join(l, separator):
    return separator.join(l)

def convert_iso_to_format(date, format):
    return parse_date(date).strftime(format)

def is_financial_procedure(auctionData):
    if  auctionData.data['procurementMethodType'] == 'dgfFinancialAssets':
        return True

    if  auctionData.data['procurementMethodType'] == 'dgfInsider':
        for item in auctionData.data['items']:
            if item['classification']['id'][0:2] == '07':
                return True

    return False
