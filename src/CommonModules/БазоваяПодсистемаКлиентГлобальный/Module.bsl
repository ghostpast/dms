///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СтандартныеПодсистемы

Процедура СП_ОбработчикОжиданияПриНачалеРаботыСистемы() Экспорт
	БазоваяПодсистемаКлиент.ПриНачалеРаботыСистемы(, Ложь);
КонецПроцедуры

Процедура СП_ОбработчикОжиданияИнтерактивнаяОбработкаПередЗавершениемРаботыСистемы() Экспорт
	БазоваяПодсистемаКлиент.СП_НачатьИнтерактивнуюОбработкуПередЗавершениемРаботыСистемы();
КонецПроцедуры

Процедура СП_ПоказатьРекомендациюПоОбъемуОперативнойПамяти() Экспорт
	БазоваяПодсистемаКлиент.СП_ОповеститьОНехваткеПамяти();
КонецПроцедуры

Процедура СП_ОбработчикОжиданияСтандартныхПериодическихПроверок() Экспорт
	БазоваяПодсистемаКлиент.СП_ПриВыполненииСтандартныхПериодическихПроверок();
КонецПроцедуры

Процедура СП_ПоказатьПредупрежденияПриЗавершенииРаботы() Экспорт
	Предупреждения	= БазоваяПодсистемаКлиент.СП_ПараметрКлиента("ПредупрежденияПриЗавершенииРаботы");
	Пояснение		= "и выполнить дополнительные действия";
	Если Предупреждения.Количество() = 1 И Не ПустаяСтрока(Предупреждения[0].ТекстГиперссылки) Тогда
		Пояснение = Предупреждения[0].ТекстГиперссылки;
	КонецЕсли;
	ПоказатьОповещениеПользователя("Нажмите, чтобы завершить работу",
		"e1cib/command/ОбщаяКоманда.ПредупрежденияПриЗавершенииРаботы",
		Пояснение, БиблиотекаКартинок.ЗавершитьРаботу, СтатусОповещенияПользователя.Важное);
КонецПроцедуры

Процедура СП_ПоказатьПредупреждениеБезопасностиПослеЗапуска() Экспорт
	ПользователиКлиент.сП_ПоказатьПредупреждениеБезопасности();
КонецПроцедуры

#КонецОбласти

#Область ОбщегоНазначения

Процедура ОН_ПодтвердитьЗакрытиеФормыСейчас() Экспорт
	БазоваяПодсистемаКлиент.сОН_ПодтвердитьЗакрытиеФормы();
КонецПроцедуры

#КонецОбласти

#Область ДлительныеОперации

Процедура ДО_КонтрольДлительныхОпераций() Экспорт
	АктивныеДлительныеОперации = БазоваяПодсистемаКлиент.ДО_АктивныеДлительныеОперации();
	Если АктивныеДлительныеОперации.Обработка Тогда
		Возврат;
	КонецЕсли;

	АктивныеДлительныеОперации.Обработка = Истина;
	Попытка
		ДО_ПроконтролироватьДлительныеОперации(АктивныеДлительныеОперации.Список);

		АктивныеДлительныеОперации.Обработка = Ложь;
	Исключение
		АктивныеДлительныеОперации.Обработка = Ложь;
		ВызватьИсключение;
	КонецПопытки;
КонецПроцедуры

Процедура ДО_ПроконтролироватьДлительныеОперации(АктивныеДлительныеОперации)
	ТекущаяДата = ТекущаяДата(); // дата сеанса не используется

	КонтролируемыеОперации	= Новый Соответствие;
	ЗаданияДляПроверки		= Новый Массив;
	ЗаданияДляОтмены		= Новый Массив;

	Для каждого ДлительнаяОперация Из АктивныеДлительныеОперации Цикл
		ДлительнаяОперация = ДлительнаяОперация.Значение;

		ОперацияОтменена = Ложь;
		Если ДлительнаяОперация.ФормаВладелец <> Неопределено И Не ДлительнаяОперация.ФормаВладелец.Открыта() Тогда
			ОперацияОтменена = Истина;
		КонецЕсли;

		Если ОперацияОтменена Тогда
			КонтролируемыеОперации.Вставить(ДлительнаяОперация.ИдентификаторЗадания, ДлительнаяОперация);
			ЗаданияДляОтмены.Добавить(ДлительнаяОперация.ИдентификаторЗадания);
		ИначеЕсли ДлительнаяОперация.Контроль <= ТекущаяДата Тогда
			КонтролируемыеОперации.Вставить(ДлительнаяОперация.ИдентификаторЗадания, ДлительнаяОперация);

			ЗаданиеДляПроверки = Новый Структура("ИдентификаторЗадания,ВыводитьПрогрессВыполнения,ВыводитьСообщения");
			ЗаполнитьЗначенияСвойств(ЗаданиеДляПроверки, ДлительнаяОперация);
			ЗаданияДляПроверки.Добавить(ЗаданиеДляПроверки);
		КонецЕсли;
	КонецЦикла;

	Статусы = Новый Соответствие;
	Статусы = БазоваяПодсистемаВызовСервера.ДО_ОперацииВыполнены(ЗаданияДляПроверки, ЗаданияДляОтмены);
	Для каждого СтатусОперации Из Статусы Цикл
		Операция = КонтролируемыеОперации[СтатусОперации.Ключ];
		Статус = СтатусОперации.Значение;
		Попытка
			Если ДО_ПроконтролироватьДлительнуюОперацию(Операция, Статус) Тогда
				АктивныеДлительныеОперации.Удалить(СтатусОперации.Ключ);
			КонецЕсли;
		Исключение
			// далее не отслеживаем
			АктивныеДлительныеОперации.Удалить(СтатусОперации.Ключ);
			ВызватьИсключение;
		КонецПопытки;
	КонецЦикла;

	Если АктивныеДлительныеОперации.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	ТекущаяДата = ТекущаяДата(); // дата сеанса не используется
	Интервал = 120;
	Для каждого Операция Из АктивныеДлительныеОперации Цикл
		Интервал = Макс(Мин(Интервал, Операция.Значение.Контроль - ТекущаяДата), 1);
	КонецЦикла;

	ПодключитьОбработчикОжидания("ДО_КонтрольДлительныхОпераций", Интервал, Истина);
КонецПроцедуры

Функция ДО_ПроконтролироватьДлительнуюОперацию(ДлительнаяОперация, Статус)
	Если Статус.Статус <> "Отменено" И ДлительнаяОперация.ОповещениеОПрогрессеВыполнения <> Неопределено Тогда
		Прогресс = Новый Структура;
		Прогресс.Вставить("Статус", Статус.Статус);
		Прогресс.Вставить("ИдентификаторЗадания", ДлительнаяОперация.ИдентификаторЗадания);
		Прогресс.Вставить("Прогресс", Статус.Прогресс);
		Прогресс.Вставить("Сообщения", Статус.Сообщения);
		ВыполнитьОбработкуОповещения(ДлительнаяОперация.ОповещениеОПрогрессеВыполнения, Прогресс);
	КонецЕсли;

	Если Статус.Статус = "Выполнено" Тогда
		БазоваяПодсистемаКлиент.ДО_ПоказатьОповещение(ДлительнаяОперация.ОповещениеПользователя);
		ДО_ВыполнитьОповещение(ДлительнаяОперация, Статус);

		Возврат Истина;
	ИначеЕсли Статус.Статус = "Ошибка" Тогда
		ДО_ВыполнитьОповещение(ДлительнаяОперация, Статус);

		Возврат Истина;
	ИначеЕсли Статус.Статус = "Отменено" Тогда
		ДО_ВыполнитьОповещение(ДлительнаяОперация, Статус);

		Возврат Истина;
	КонецЕсли;

	ИнтервалОжидания = ДлительнаяОперация.ТекущийИнтервал;
	Если ДлительнаяОперация.Интервал = 0 Тогда
		ИнтервалОжидания = ИнтервалОжидания * 1.4;
		Если ИнтервалОжидания > 15 Тогда
			ИнтервалОжидания = 15;
		КонецЕсли;
		ДлительнаяОперация.ТекущийИнтервал = ИнтервалОжидания;
	КонецЕсли;
	ДлительнаяОперация.Контроль = ТекущаяДата() + ИнтервалОжидания;  // дата сеанса не используется

	Возврат Ложь;
КонецФункции

Процедура ДО_ВыполнитьОповещение(Знач ДлительнаяОперация, Знач Статус)
	Если ДлительнаяОперация.ОповещениеОЗавершении = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Статус.Статус = "Отменено" Тогда
		Результат = Неопределено;
	Иначе
		Результат = Новый Структура;
		Результат.Вставить("Статус",    Статус.Статус);
		Если ДлительнаяОперация.Свойство("АдресРезультата") Тогда
			Результат.Вставить("АдресРезультата", ДлительнаяОперация.АдресРезультата);
		КонецЕсли;
		Если ДлительнаяОперация.Свойство("АдресДополнительногоРезультата") Тогда
			Результат.Вставить("АдресДополнительногоРезультата", ДлительнаяОперация.АдресДополнительногоРезультата);
		КонецЕсли;
		Результат.Вставить("КраткоеПредставлениеОшибки",	Статус.КраткоеПредставлениеОшибки);
		Результат.Вставить("ПодробноеПредставлениеОшибки",	Статус.ПодробноеПредставлениеОшибки);
		Результат.Вставить("Сообщения",						Статус.Сообщения);
	КонецЕсли;

	ВыполнитьОбработкуОповещения(ДлительнаяОперация.ОповещениеОЗавершении, Результат);
КонецПроцедуры

#КонецОбласти
