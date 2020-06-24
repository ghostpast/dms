///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СтандартныеПодсистемы

Функция СП_ПараметрыРаботыКлиентаПриЗапуске() Экспорт
	СП_ПроверитьПорядокЗапускаПрограммыПередНачаломРаботыСистемы();

	ПараметрыПриЗапускеПрограммы = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыПриЗапускеПрограммы"];

	Параметры = Новый Структура;
	Параметры.Вставить("ПолученныеПараметрыКлиента", Неопределено);

	Если ПараметрыПриЗапускеПрограммы.Свойство("ПолученныеПараметрыКлиента")
		И ТипЗнч(ПараметрыПриЗапускеПрограммы.ПолученныеПараметрыКлиента) = Тип("Структура") Тогда

		Параметры.Вставить("ПолученныеПараметрыКлиента", БазоваяПодсистемаКлиент.ОН_СкопироватьРекурсивно(
			ПараметрыПриЗапускеПрограммы.ПолученныеПараметрыКлиента));
	КонецЕсли;

	Если ПараметрыПриЗапускеПрограммы.Свойство("ПропуститьОчисткуСкрытияРабочегоСтола") Тогда
		Параметры.Вставить("ПропуститьОчисткуСкрытияРабочегоСтола");
	КонецЕсли;

	Параметры.Вставить("ПараметрЗапуска",							ПараметрЗапуска);
	Параметры.Вставить("СтрокаСоединенияИнформационнойБазы",		СтрокаСоединенияИнформационнойБазы());
	Параметры.Вставить("ЭтоВебКлиент",								СП_ЭтоВебКлиент());
	Параметры.Вставить("ЭтоLinuxКлиент",							БазоваяПодсистемаКлиент.ОН_ЭтоLinuxКлиент());
	Параметры.Вставить("ЭтоMacOSКлиент",							БазоваяПодсистемаКлиент.ОН_ЭтоMacOSКлиент());
	Параметры.Вставить("ЭтоWindowsКлиент",							БазоваяПодсистемаКлиент.ОН_ЭтоWindowsКлиент());
	Параметры.Вставить("ЭтоМобильныйКлиент",						СП_ЭтоМобильныйКлиент());
	Параметры.Вставить("ИспользуемыйКлиент",						СП_ИспользуемыйКлиент());
	Параметры.Вставить("КаталогПрограммы",							СП_ТекущийКаталогПрограммы());
	Параметры.Вставить("ИдентификаторКлиента",						СП_ИдентификаторКлиента());
	Параметры.Вставить("СкрытьРабочийСтолПриНачалеРаботыСистемы",	Ложь);
	Параметры.Вставить("ОперативнаяПамять",							БазоваяПодсистемаКлиент.ОН_ОперативнаяПамятьДоступнаяКлиентскомуПриложению());
	Параметры.Вставить("РазрешениеОсновногоЭкрана",					СП_РазрешениеОсновногоЭкрана());

	// Установка даты клиента непосредственно перед вызовом, чтобы уменьшить погрешность.
	Параметры.Вставить("ТекущаяДатаНаКлиенте",								ТекущаяДата()); // Для расчета ПоправкаКВремениСеанса.
	Параметры.Вставить("ТекущаяУниверсальнаяДатаВМиллисекундахНаКлиенте",	ТекущаяУниверсальнаяДатаВМиллисекундах());

	Если ПараметрыПриЗапускеПрограммы.Свойство("ОпцииИнтерфейса")
	   И ТипЗнч(Параметры.ПолученныеПараметрыКлиента) = Тип("Структура") Тогда

		Параметры.ПолученныеПараметрыКлиента.Вставить("ОпцииИнтерфейса");
	КонецЕсли;

	ПараметрыКлиента = БазоваяПодсистемаВызовСервера.СП_ПараметрыРаботыКлиентаПриЗапуске(Параметры);

	Если ПараметрыПриЗапускеПрограммы.Свойство("ПолученныеПараметрыКлиента")
		И ПараметрыПриЗапускеПрограммы.ПолученныеПараметрыКлиента <> Неопределено
		И Не ПараметрыПриЗапускеПрограммы.Свойство("ОпцииИнтерфейса") Тогда

		ПараметрыПриЗапускеПрограммы.Вставить("ОпцииИнтерфейса", ПараметрыКлиента.ОпцииИнтерфейса);
	КонецЕсли;

	БазоваяПодсистемаКлиент.СП_ЗаполнитьПараметрыКлиента(ПараметрыКлиента);

	// Обновление состояния скрытия рабочего стола на клиенте по состоянию на сервере.
	БазоваяПодсистемаКлиент.СП_СкрытьРабочийСтолПриНачалеРаботыСистемы(
		Параметры.СкрытьРабочийСтолПриНачалеРаботыСистемы, Истина);

	Возврат ПараметрыКлиента;
КонецФункции

Функция СП_ПараметрыРаботыКлиента() Экспорт
	СП_ПроверитьПорядокЗапускаПрограммыПередНачаломРаботыСистемы();
	СП_ПроверитьПорядокЗапускаПрограммыПриНачалеРаботыСистемы();

	СвойстваКлиента = Новый Структура;

	// Установка даты клиента непосредственно перед вызовом, чтобы уменьшить погрешность.
	СвойстваКлиента.Вставить("ТекущаяДатаНаКлиенте", ТекущаяДата()); // Для расчета ПоправкаКВремениСеанса.
	СвойстваКлиента.Вставить("ТекущаяУниверсальнаяДатаВМиллисекундахНаКлиенте",
		ТекущаяУниверсальнаяДатаВМиллисекундах());

	Возврат БазоваяПодсистемаВызовСервера.СП_ПараметрыРаботыКлиента(СвойстваКлиента);
КонецФункции

Процедура СП_ПроверитьПорядокЗапускаПрограммыПередНачаломРаботыСистемы()
	ИмяПараметра = "СтандартныеПодсистемы.ЗапускПрограммыЗавершен";
	Если ПараметрыПриложения[ИмяПараметра] = Неопределено Тогда
		ВызватьИсключение
			"Ошибка порядка запуска программы.
				|Первой процедурой, которая вызывается из обработчика события ПередНачаломРаботыСистемы
				|должна быть процедура БазоваяПодсистемаКлиент.СП_ПередНачаломРаботыСистемы.";
	КонецЕсли;
КонецПроцедуры

Процедура СП_ПроверитьПорядокЗапускаПрограммыПриНачалеРаботыСистемы()
	Если Не БазоваяПодсистемаКлиент.СП_ЗапускПрограммыЗавершен() Тогда
		ВызватьИсключение
			"Ошибка порядка запуска программы.
				|Перед получением параметров работы клиента запуск программы должен быть завершен.";
	КонецЕсли;
КонецПроцедуры

Функция СП_ЭтоВебКлиент() Экспорт
#Если ВебКлиент Тогда
	Возврат Истина;
#Иначе
	Возврат Ложь;
#КонецЕсли
КонецФункции

Функция СП_ЭтоМобильныйКлиент() Экспорт
#Если МобильныйКлиент Тогда
	Возврат Истина;
#Иначе
	Возврат Ложь;
#КонецЕсли
КонецФункции

Функция СП_ИспользуемыйКлиент()
	ИспользуемыйКлиент = "";
	#Если ТонкийКлиент Тогда
		ИспользуемыйКлиент = "ТонкийКлиент";
	#ИначеЕсли ТолстыйКлиентУправляемоеПриложение Тогда
		ИспользуемыйКлиент = "ТолстыйКлиентУправляемоеПриложение";
	#ИначеЕсли ВебКлиент Тогда
		ОписаниеБраузера = СП_ТекущийБраузер();
		Если ПустаяСтрока(ОписаниеБраузера.Версия) Тогда
			ИспользуемыйКлиент = СтрШаблон("ВебКлиент.%1", ОписаниеБраузера.Название);
		Иначе
			ИспользуемыйКлиент = СтрШаблон("ВебКлиент.%1.%2", ОписаниеБраузера.Название, СтрРазделить(ОписаниеБраузера.Версия, ".")[0]);
		КонецЕсли;
	#КонецЕсли

	Возврат ИспользуемыйКлиент;
КонецФункции

Функция СП_ТекущийБраузер()
	Результат = Новый Структура("Название,Версия", "Другой", "");

	СистемнаяИнформация	= Новый СистемнаяИнформация;
	Строка				= СистемнаяИнформация.ИнформацияПрограммыПросмотра;
	Строка				= СтрЗаменить(Строка, ",", ";");

	// Opera
	Идентификатор	= "Opera";
	Позиция			= СтрНайти(Строка, Идентификатор, НаправлениеПоиска.СКонца);
	Если Позиция > 0 Тогда
		Строка				= Сред(Строка, Позиция + СтрДлина(Идентификатор));
		Результат.Название	= "Opera";
		Идентификатор		= "Version/";
		Позиция				= СтрНайти(Строка, Идентификатор);
		Если Позиция > 0 Тогда
			Строка				= Сред(Строка, Позиция + СтрДлина(Идентификатор));
			Результат.Версия	= СокрЛП(Строка);
		Иначе
			Строка = СокрЛП(Строка);
			Если СтрНачинаетсяС(Строка, "/") Тогда
				Строка = Сред(Строка, 2);
			КонецЕсли;
			Результат.Версия = СокрЛ(Строка);
		КонецЕсли;

		Возврат Результат;
	КонецЕсли;

	// IE
	Идентификатор	= "MSIE"; // v11-
	Позиция			= СтрНайти(Строка, Идентификатор);
	Если Позиция > 0 Тогда
		Результат.Название	= "IE";
		Строка				= Сред(Строка, Позиция + СтрДлина(Идентификатор));
		Позиция				= СтрНайти(Строка, ";");
		Если Позиция > 0 Тогда
			Строка				= СокрЛ(Лев(Строка, Позиция - 1));
			Результат.Версия	= Строка;
		КонецЕсли;

		Возврат Результат;
	КонецЕсли;

	Идентификатор	= "Trident"; // v11+
	Позиция			= СтрНайти(Строка, Идентификатор);
	Если Позиция > 0 Тогда
		Результат.Название	= "IE";
		Строка				= Сред(Строка, Позиция + СтрДлина(Идентификатор));

		Идентификатор		= "rv:";
		Позиция				= СтрНайти(Строка, Идентификатор);
		Если Позиция > 0 Тогда
			Строка	= Сред(Строка, Позиция + СтрДлина(Идентификатор));
			Позиция	= СтрНайти(Строка, ")");
			Если Позиция > 0 Тогда
				Строка				= СокрЛ(Лев(Строка, Позиция - 1));
				Результат.Версия	= Строка;
			КонецЕсли;
		КонецЕсли;

		Возврат Результат;
	КонецЕсли;

	// Chrome
	Идентификатор	= "Chrome/";
	Позиция			= СтрНайти(Строка, Идентификатор);
	Если Позиция > 0 Тогда
		Результат.Название	= "Chrome";
		Строка				= Сред(Строка, Позиция + СтрДлина(Идентификатор));
		Позиция				= СтрНайти(Строка, " ");
		Если Позиция > 0 Тогда
			Строка				= СокрЛ(Лев(Строка, Позиция - 1));
			Результат.Версия	= Строка;
		КонецЕсли;

		Возврат Результат;
	КонецЕсли;

	// Safari
	Идентификатор = "Safari/";
	Если СтрНайти(Строка, Идентификатор) > 0 Тогда
		Результат.Название	= "Safari";
		Идентификатор		= "Version/";
		Позиция				= СтрНайти(Строка, Идентификатор);
		Если Позиция > 0 Тогда
			Строка	= Сред(Строка, Позиция + СтрДлина(Идентификатор));
			Позиция	= СтрНайти(Строка, " ");
			Если Позиция > 0 Тогда
				Результат.Версия = СокрЛП(Лев(Строка, Позиция - 1));
			КонецЕсли;
		КонецЕсли;

		Возврат Результат;
	КонецЕсли;

	// Firefox
	Идентификатор	= "Firefox/";
	Позиция			= СтрНайти(Строка, Идентификатор);
	Если Позиция > 0 Тогда
		Результат.Название	= "Firefox";
		Строка				= Сред(Строка, Позиция + СтрДлина(Идентификатор));
		Если Не ПустаяСтрока(Строка) Тогда
			Результат.Версия = СокрЛП(Строка);
		КонецЕсли;

		Возврат Результат;
	КонецЕсли;

	Возврат Результат;
КонецФункции

Функция СП_ТекущийКаталогПрограммы()
	#Если ВебКлиент Или МобильныйКлиент Тогда
		КаталогПрограммы = "";
	#Иначе
		КаталогПрограммы = КаталогПрограммы();
	#КонецЕсли

	Возврат КаталогПрограммы;
КонецФункции

Функция СП_ИдентификаторКлиента()
	СистемнаяИнформация = Новый СистемнаяИнформация;

	Возврат СистемнаяИнформация.ИдентификаторКлиента;
КонецФункции

Функция СП_РазрешениеОсновногоЭкрана()
	ИнформацияЭкрановКлиента = ПолучитьИнформациюЭкрановКлиента();
	Если ИнформацияЭкрановКлиента.Количество() > 0 Тогда
		DPI							= ИнформацияЭкрановКлиента[0].DPI;
		РазрешениеОсновногоЭкрана	= ?(DPI = 0, 72, DPI);
	Иначе
		РазрешениеОсновногоЭкрана	= 72;
	КонецЕсли;

	Возврат РазрешениеОсновногоЭкрана;
КонецФункции

#КонецОбласти

