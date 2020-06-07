///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Функция НеобходимоОбновление(НастройкаПодчиненногоУзлаРИБ = Ложь) Экспорт
	// Обновление в локальном режиме.
	Если ОбновлениеВерсииИБСерверПовтИсп.сОИБ_НеобходимоОбновлениеИнформационнойБазы() Тогда
		Возврат Истина;
	КонецЕсли;

	// Зарезервировано для новых подсистем

	Возврат Ложь;
КонецФункции

Процедура УстановитьПараметрРаботыПрограммы(ИмяПараметра, Значение) Экспорт
	Если БазоваяПодсистемаСервер.СП_ВерсияПрограммыОбновленаДинамически() Тогда
		ВызватьИсключение "Версия программы обновлена, требуется перезапустить сеанс.";
	КонецЕсли;

	ОписаниеЗначения = Новый Структура;
	ОписаниеЗначения.Вставить("Версия", Метаданные.Версия);
	ОписаниеЗначения.Вставить("Значение", Значение);

	УстановитьХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра, ОписаниеЗначения);
КонецПроцедуры

Процедура ОбновитьПараметрРаботыПрограммы(ИмяПараметра, Значение, ЕстьИзменения = Ложь, СтароеЗначение = Неопределено) Экспорт
	БазоваяПодсистемаСервер.СП_ПроверитьДинамическоеОбновлениеВерсииПрограммы();

	ОписаниеЗначения = ОписаниеЗначенияПараметраРаботыПрограммы(ИмяПараметра);
	СтароеЗначение = ОписаниеЗначения.Значение;

	Если Не БазоваяПодсистемаСервер.ОН_ДанныеСовпадают(Значение, СтароеЗначение) Тогда
		ЕстьИзменения = Истина;
	ИначеЕсли ОписаниеЗначения.Версия = Метаданные.Версия Тогда
		Возврат;
	КонецЕсли;

	УстановитьПараметрРаботыПрограммы(ИмяПараметра, Значение);
КонецПроцедуры

Функция ПараметрРаботыПрограммы(ИмяПараметра) Экспорт
	ОписаниеЗначения = ОписаниеЗначенияПараметраРаботыПрограммы(ИмяПараметра);

	Если БазоваяПодсистемаСервер.СП_ВерсияПрограммыОбновленаДинамически() Тогда
		Возврат ОписаниеЗначения.Значение;
	КонецЕсли;

	Если ОписаниеЗначения.Версия <> Метаданные.Версия Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат ОписаниеЗначения.Значение;
КонецФункции

Функция ОписаниеЗначенияПараметраРаботыПрограммы(ИмяПараметра)
	ОписаниеЗначения = ХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра);

	Если ТипЗнч(ОписаниеЗначения) <> Тип("Структура")
	 Или ОписаниеЗначения.Количество() <> 2
	 Или Не ОписаниеЗначения.Свойство("Версия")
	 Или Не ОписаниеЗначения.Свойство("Значение") Тогда

		Если БазоваяПодсистемаСервер.СП_ВерсияПрограммыОбновленаДинамически() Тогда
			ВызватьИсключение "Версия программы обновлена, требуется перезапустить сеанс.";
		КонецЕсли;
		ОписаниеЗначения = Новый Структура("Версия, Значение");
	КонецЕсли;

	Возврат ОписаниеЗначения;
КонецФункции

Функция ХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра)
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИмяПараметра", ИмяПараметра);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПараметрыРаботыПрограммы.ХранилищеПараметра
	|ИЗ
	|	РегистрСведений.ПараметрыРаботыПрограммы КАК ПараметрыРаботыПрограммы
	|ГДЕ
	|	ПараметрыРаботыПрограммы.ИмяПараметра = &ИмяПараметра";

	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ХранилищеПараметра.Получить();
	КонецЕсли;
	УстановитьПривилегированныйРежим(Ложь);
	УстановитьОтключениеБезопасногоРежима(Ложь);

	Возврат Неопределено;
КонецФункции

Процедура УстановитьХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра, ХранимыеДанные)
	НаборЗаписей					= СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ИмяПараметра.Установить(ИмяПараметра);

	НоваяЗапись						= НаборЗаписей.Добавить();
	НоваяЗапись.ИмяПараметра		= ИмяПараметра;
	НоваяЗапись.ХранилищеПараметра	= Новый ХранилищеЗначения(ХранимыеДанные);

	ОбновлениеВерсииИБСервер.ОИБ_ЗаписатьНаборЗаписей(НаборЗаписей, , Ложь, Ложь);
КонецПроцедуры

#КонецЕсли
