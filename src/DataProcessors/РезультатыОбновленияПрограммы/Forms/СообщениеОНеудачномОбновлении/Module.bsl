///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// Зарезервировано для новых подсистем

	Если ЗначениеЗаполнено(Параметры.ПодробноеПредставлениеОшибки) Тогда
		БазоваяПодсистемаСервер.ЖР_ДобавитьСообщениеДляЖурналаРегистрации("Обновление информационной базы", УровеньЖурналаРегистрации.Ошибка,,, Параметры.ПодробноеПредставлениеОшибки);
	КонецЕсли;

	ТекстСообщенияОбОшибке = СтрШаблон("При обновлении версии программы возникла ошибка:
		|
		|%1",
		Параметры.КраткоеПредставлениеОшибки);

	Элементы.ТекстСообщенияОбОшибке.Заголовок	= ТекстСообщенияОбОшибке;

	ВремяНачалаОбновления		= Параметры.ВремяНачалаОбновления;
	ВремяОкончанияОбновления	= ТекущаяДатаСеанса();

	Если Не ПользователиСервер.П_ЭтоПолноправныйПользователь(, Истина) Тогда
		Элементы.ФормаОткрытьВнешнююОбработку.Видимость = Ложь;
	КонецЕсли;

	// Зарезервировано для новых подсистем

	ИспользуютсяПрофилиБезопасности = Ложь;

	// Зарезервировано для новых подсистем
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	// Зарезервировано для новых подсистем
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьСведенияОРезультатахОбновленияНажатие(Элемент)
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ДатаНачала",		ВремяНачалаОбновления);
	ПараметрыФормы.Вставить("ДатаОкончания",	ВремяОкончанияОбновления);
	ПараметрыФормы.Вставить("ЗапускатьНеВФоне",	Истина);

	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ПараметрыФормы,,,,,, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьРаботу(Команда)
	Закрыть(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ПерезагрузитьПрограмму(Команда)
	Закрыть(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьВнешнююОбработку(Команда)
	ОбработкаПродолжения = Новый ОписаниеОповещения("ОткрытьВнешнююОбработкуПослеПодтвержденияБезопасности", ЭтотОбъект);
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ПредупреждениеБезопасности",,,,,, ОбработкаПродолжения);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьВнешнююОбработкуПослеПодтвержденияБезопасности(Результат, ДополнительныеПараметры) Экспорт
	Если Результат <> Истина Тогда
		Возврат;
	КонецЕсли;

	// Зарезервировано для новых подсистем

	Оповещение = Новый ОписаниеОповещения("ОткрытьВнешнююОбработкуЗавершение", ЭтотОбъект);
	ПараметрыЗагрузки							= БазоваяПодсистемаКлиент.ФС_ПараметрыЗагрузкиФайла();
	ПараметрыЗагрузки.ИдентификаторФормы		= УникальныйИдентификатор;
	ПараметрыЗагрузки.Диалог.Фильтр				= "Внешняя обработка(*.epf)|*.epf";
	ПараметрыЗагрузки.Диалог.МножественныйВыбор	= Ложь;
	ПараметрыЗагрузки.Диалог.Заголовок			= "Выберите внешнюю обработку";
	БазоваяПодсистемаКлиент.ФС_ЗагрузитьФайл(Оповещение, ПараметрыЗагрузки);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьВнешнююОбработкуЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если ТипЗнч(Результат) = Тип("Структура") Тогда
		ИмяВнешнейОбработки = ПодключитьВнешнююОбработку(Результат.Хранение);
		ОткрытьФорму(ИмяВнешнейОбработки + ".Форма");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПодключитьВнешнююОбработку(АдресВоВременномХранилище)
	Если Не ПользователиСервер.П_ЭтоПолноправныйПользователь(, Истина) Тогда
		ВызватьИсключение "Недостаточно прав доступа.";
	КонецЕсли;

	Менеджер		= ВнешниеОбработки;
	ИмяОбработки	= Менеджер.Подключить(АдресВоВременномХранилище, , Ложь, БазоваяПодсистемаСервер.ОН_ОписаниеЗащитыБезПредупреждений());

	Возврат Менеджер.Создать(ИмяОбработки, Ложь).Метаданные().ПолноеИмя();
КонецФункции
