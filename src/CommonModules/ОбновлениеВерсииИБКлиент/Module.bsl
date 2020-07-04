///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбновлениеИнформационнойБазы

Процедура ПередНачаломРаботыСистемы(Параметры) Экспорт
	ПараметрыКлиента = БазоваяПодсистемаКлиентПовтИсп.СП_ПараметрыРаботыКлиентаПриЗапуске();

	Если ПараметрыКлиента.Свойство("ИнформационнаяБазаЗаблокированаДляОбновления") Тогда
		Кнопки	= Новый СписокЗначений;
		Кнопки.Добавить("Перезапустить", "Перезапустить");
		Кнопки.Добавить("Завершить",     "Завершить работу");

		ПараметрыВопроса	= Новый Структура;
		ПараметрыВопроса.Вставить("КнопкаПоУмолчанию",	"Перезапустить");
		ПараметрыВопроса.Вставить("КнопкаТаймаута",		"Перезапустить");
		ПараметрыВопроса.Вставить("Таймаут",			60);

		ОписаниеПредупреждения	= Новый Структура;
		ОписаниеПредупреждения.Вставить("Кнопки",				Кнопки);
		ОписаниеПредупреждения.Вставить("ПараметрыВопроса",		ПараметрыВопроса);
		ОписаниеПредупреждения.Вставить("ТекстПредупреждения",	ПараметрыКлиента.ИнформационнаяБазаЗаблокированаДляОбновления);

		Параметры.Отказ						= Истина;
		Параметры.ИнтерактивнаяОбработка	= Новый ОписаниеОповещения("СП_ПоказатьПредупреждениеИПродолжить", БазоваяПодсистемаКлиент, ОписаниеПредупреждения);
	КонецЕсли;
КонецПроцедуры

Процедура ПередНачаломРаботыСистемы2(Параметры) Экспорт
	ПараметрыКлиента = БазоваяПодсистемаКлиентПовтИсп.СП_ПараметрыРаботыКлиентаПриЗапуске();
	Если ПараметрыКлиента.Свойство("НеобходимоВыполнитьОбработчикиОтложенногоОбновления") Тогда
		Параметры.ИнтерактивнаяОбработка = Новый ОписаниеОповещения("ОИБ_ИнтерактивнаяОбработкаПроверкиСтатусаОтложенногоОбновления", ЭтотОбъект);
	КонецЕсли;
КонецПроцедуры

Процедура ПередНачаломРаботыСистемы3(Параметры) Экспорт
	ПараметрыКлиента	= БазоваяПодсистемаКлиентПовтИсп.СП_ПараметрыРаботыКлиентаПриЗапуске();
	Если ПараметрыКлиента.Свойство("НеобходимоОбновлениеПараметровРаботыПрограммы") Тогда
		Параметры.ИнтерактивнаяОбработка = Новый ОписаниеОповещения("ОИБ_ЗагрузитьОбновитьПараметрыРаботыПрограммы", ОбновлениеВерсииИБКлиент);
	КонецЕсли;
КонецПроцедуры

Процедура ПередНачаломРаботыСистемы4(Параметры) Экспорт
	ПараметрыРаботыКлиента = БазоваяПодсистемаКлиентПовтИсп.СП_ПараметрыРаботыКлиентаПриЗапуске();
	Если НЕ ПараметрыРаботыКлиента.ДоступноИспользованиеРазделенныхДанных Тогда
		ОИБ_ЗакрытьФормуИндикацииХодаОбновленияЕслиОткрыта(Параметры);

		Возврат;
	КонецЕсли;

	Если ПараметрыРаботыКлиента.Свойство("НеобходимоОбновлениеИнформационнойБазы") Тогда
		Параметры.ИнтерактивнаяОбработка = Новый ОписаниеОповещения("ОИБ_НачатьОбновлениеИнформационнойБазы", ЭтотОбъект);
	Иначе
		Если ПараметрыРаботыКлиента.Свойство("ЗагрузитьСообщениеОбменаДанными") Тогда
			Перезапустить	= Ложь;
			ОбновлениеВерсииИБВызовСервера.сОИБ_ВыполнитьОбновлениеИнформационнойБазы(Истина, Перезапустить);
			Если Перезапустить Тогда
				Параметры.Отказ			= Истина;
				Параметры.Перезапустить	= Истина;
			КонецЕсли;
		КонецЕсли;
		ОИБ_ЗакрытьФормуИндикацииХодаОбновленияЕслиОткрыта(Параметры);
	КонецЕсли;
КонецПроцедуры

Процедура ПередНачаломРаботыСистемы5(Параметры) Экспорт
	Если БазоваяПодсистемаКлиент.ОН_ИнформационнаяБазаФайловая() И СтрНайти(ПараметрЗапуска, "ВыполнитьОбновлениеИЗавершитьРаботу") > 0 Тогда
		ПрекратитьРаботуСистемы();
	КонецЕсли;
КонецПроцедуры

Процедура ОИБ_НачатьОбновлениеИнформационнойБазы(Параметры, ОбработкаПродолжения) Экспорт
	ИмяПараметра	= "СтандартныеПодсистемы.ОбновлениеВерсииИБ.ФормаИндикацияХодаОбновленияИБ";
	Форма			= ПараметрыПриложения.Получить(ИмяПараметра);

	Если Форма = Неопределено Тогда
		ИмяФормы	= "Обработка.РезультатыОбновленияПрограммы.Форма.ИндикацияХодаОбновленияИБ";
		Форма		= ОткрытьФорму(ИмяФормы,,,,,, Новый ОписаниеОповещения("ОИБ_ПослеЗакрытияФормыИндикацияХодаОбновленияИБ", ЭтотОбъект, Параметры));
		ПараметрыПриложения.Вставить(ИмяПараметра, Форма);
	КонецЕсли;

	Форма.ОбновитьИнформационнуюБазу();
КонецПроцедуры

Процедура ОИБ_ПослеНачалаРаботыСистемы() Экспорт
	ПараметрыКлиента = БазоваяПодсистемаКлиентПовтИсп.СП_ПараметрыРаботыКлиентаПриЗапуске();

	Если ПараметрыКлиента.Свойство("ПоказатьСообщениеОбОшибочныхОбработчиках")
		Или ПараметрыКлиента.Свойство("ПоказатьОповещениеОНевыполненныхОбработчиках") Тогда

		ПодключитьОбработчикОжидания("ОИБ_ПроверитьСтатусОтложенногоОбновления", 2, Истина);
	КонецЕсли;
КонецПроцедуры

Процедура ОИБ_ЗагрузитьОбновитьПараметрыРаботыПрограммы(Параметры, Контекст) Экспорт
	ИмяФормы = "Обработка.РезультатыОбновленияПрограммы.Форма.ИндикацияХодаОбновленияИБ";
	Форма = ОткрытьФорму(ИмяФормы,,,,,, Новый ОписаниеОповещения("ОИБ_ПослеЗакрытияФормыИндикацияХодаОбновленияИБ", ЭтотОбъект, Параметры));
	ПараметрыПриложения.Вставить("СтандартныеПодсистемы.ОбновлениеВерсииИБ.ФормаИндикацияХодаОбновленияИБ", Форма);
	Форма.ЗагрузитьОбновитьПараметрыРаботыПрограммы(Параметры);
КонецПроцедуры

Процедура ОИБ_ПослеЗакрытияФормыИндикацияХодаОбновленияИБ(Результат, Параметры) Экспорт
	Если ТипЗнч(Результат) <> Тип("Структура") Тогда
		Результат = Новый Структура("Отказ, Перезапустить", Истина, Ложь);
	КонецЕсли;

	Если Результат.Отказ Тогда
		Параметры.Отказ = Истина;
		Если Результат.Перезапустить Тогда
			Параметры.Перезапустить = Истина;
		КонецЕсли;
	КонецЕсли;

	ВыполнитьОбработкуОповещения(Параметры.ОбработкаПродолжения);
КонецПроцедуры

Процедура ОИБ_ИнтерактивнаяОбработкаПроверкиСтатусаОтложенногоОбновления(Параметры, Контекст) Экспорт
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ОтложенноеОбновлениеНеЗавершено",,,,,, Новый ОписаниеОповещения("ОИБ_ПослеЗакрытияФормыПроверкиСтатусаОтложенногоОбновления",ЭтотОбъект, Параметры));
КонецПроцедуры

Процедура ОИБ_ПослеЗакрытияФормыПроверкиСтатусаОтложенногоОбновления(Результат, Параметры) Экспорт
	Если Результат <> Истина Тогда
		Параметры.Отказ = Истина;
	КонецЕсли;

	ВыполнитьОбработкуОповещения(Параметры.ОбработкаПродолжения);
КонецПроцедуры

Процедура ОИБ_ОповеститьОтложенныеОбработчикиНеВыполнены() Экспорт
	Если БазоваяПодсистемаКлиент.СП_ПараметрКлиента("ЭтоСеансВнешнегоПользователя") Тогда
		Возврат;
	КонецЕсли;

	ПоказатьОповещениеПользователя(
		"Работа в программе временно ограничена",
		"e1cib/app/Обработка.РезультатыОбновленияПрограммы",
		"Не завершен переход на новую версию",
		БиблиотекаКартинок.Предупреждение32);
КонецПроцедуры

Процедура ОИБ_ЗакрытьФормуИндикацииХодаОбновленияЕслиОткрыта(Параметры)
	ИмяПараметра	= "СтандартныеПодсистемы.ОбновлениеВерсииИБ.ФормаИндикацияХодаОбновленияИБ";
	Форма			= ПараметрыПриложения.Получить(ИмяПараметра);
	Если Форма = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Если Форма.Открыта() Тогда
		Форма.НачатьЗакрытие();
	КонецЕсли;
	ПараметрыПриложения.Удалить(ИмяПараметра);
КонецПроцедуры

#КонецОбласти
