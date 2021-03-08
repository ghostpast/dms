///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СтандартныеПодсистемы

Функция СП_ОписанияПодсистем() Экспорт
	МодулиПодсистем = Новый Массив;
	МодулиПодсистем.Добавить("ОбновлениеВерсииИБСервер");

	ИнтеграцияПодсистемСервер.ПриДобавленииПодсистем(МодулиПодсистем);
	УправлениеАвтоцентромСервер.ПриДобавленииПодсистем(МодулиПодсистем);

	ОписаниеКонфигурацииНайдено	= Ложь;
	ОписанияПодсистем			= Новый Структура;
	ОписанияПодсистем.Вставить("Порядок",  Новый Массив);
	ОписанияПодсистем.Вставить("ПоИменам", Новый Соответствие);

	ВсеТребуемыеПодсистемы = Новый Соответствие;

	Для Каждого ИмяМодуля Из МодулиПодсистем Цикл
		Описание = Новый Структура;
		Описание.Вставить("Имя",										"");
		Описание.Вставить("Версия",										"");
		Описание.Вставить("ТребуемыеПодсистемы",						Новый Массив);
		Описание.Вставить("ИдентификаторИнтернетПоддержки",				"");
		// Свойство устанавливается автоматически.
		Описание.Вставить("ЭтоКонфигурация",							Ложь);
		// Имя основного модуля библиотеки.
		// Может быть пустым для конфигурации.
		Описание.Вставить("ОсновнойСерверныйМодуль",					"");
		// Режим выполнения отложенных обработчиков обновления.
		// По умолчанию Последовательно.
		Описание.Вставить("РежимВыполненияОтложенныхОбработчиков",		"Последовательно");
		Описание.Вставить("ПараллельноеОтложенноеОбновлениеСВерсии",	"");

		Модуль = БазоваяПодсистемаСервер.ОН_ОбщийМодуль(ИмяМодуля);
		Модуль.ПриДобавленииПодсистемы(Описание);

		Если ОписанияПодсистем.ПоИменам.Получить(Описание.Имя) <> Неопределено Тогда
			ТекстОшибки = СтрШаблон(
				"Ошибка при подготовке описаний подсистем:
				           |в описании подсистемы (см. процедуру %1.ПриДобавленииПодсистемы)
				           |указано имя подсистемы ""%2"", которое уже зарегистрировано ранее.",
				ИмяМодуля, Описание.Имя);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;

		Если Описание.Имя = Метаданные.Имя Тогда
			ОписаниеКонфигурацииНайдено = Истина;
			Описание.Вставить("ЭтоКонфигурация", Истина);
		Иначе
			Описание.Вставить("ЭтоКонфигурация", Ложь);
		КонецЕсли;

		Описание.Вставить("ОсновнойСерверныйМодуль", ИмяМодуля);

		ОписанияПодсистем.ПоИменам.Вставить(Описание.Имя, Описание);
		// Настройка порядка подсистем с учетом порядка добавления основных модулей.
		ОписанияПодсистем.Порядок.Добавить(Описание.Имя);
		// Сборка всех требуемых подсистем.
		Для каждого ТребуемаяПодсистема Из Описание.ТребуемыеПодсистемы Цикл
			Если ВсеТребуемыеПодсистемы.Получить(ТребуемаяПодсистема) = Неопределено Тогда
				ВсеТребуемыеПодсистемы.Вставить(ТребуемаяПодсистема, Новый Массив);
			КонецЕсли;
			ВсеТребуемыеПодсистемы[ТребуемаяПодсистема].Добавить(Описание.Имя);
		КонецЦикла;
	КонецЦикла;

	// Проверка описания основной конфигурации.
	Если ОписаниеКонфигурацииНайдено Тогда
		Описание = ОписанияПодсистем.ПоИменам[Метаданные.Имя];

		Если Описание.Версия <> Метаданные.Версия Тогда
			ТекстОшибки = СтрШаблон(
				"Ошибка при подготовке описаний подсистем:
				           |версия ""%2"" конфигурации ""%1"" (см. процедуру %3.ПриДобавленииПодсистемы)
				           |не совпадает с версией конфигурации в метаданных ""%4"".",
				Описание.Имя,
				Описание.Версия,
				Описание.ОсновнойСерверныйМодуль,
				Метаданные.Версия);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	Иначе
		ТекстОшибки = СтрШаблон(
			"Ошибка при подготовке описаний подсистем:
			           |в общих модулях, указанных в процедуре ПодсистемыКонфигурации.ПриДобавленииПодсистемы
			           |не существует описание подсистемы, совпадающей с именем конфигурации ""%1"".",
			Метаданные.Имя);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	// Проверка наличия всех требуемых подсистем.
	Для каждого КлючИЗначение Из ВсеТребуемыеПодсистемы Цикл
		Если ОписанияПодсистем.ПоИменам.Получить(КлючИЗначение.Ключ) = Неопределено Тогда
			ЗависимыеПодсистемы = "";
			Для Каждого ЗависимаяПодсистема Из КлючИЗначение.Значение Цикл
				ЗависимыеПодсистемы = Символы.ПС + ЗависимаяПодсистема;
			КонецЦикла;
			ТекстОшибки = СтрШаблон(
				"Ошибка при подготовке описаний подсистем:
				           |не существует подсистема ""%1"" требуемая для подсистем: %2.",
				КлючИЗначение.Ключ,
				ЗависимыеПодсистемы);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	КонецЦикла;

	// Настройка порядка подсистем с учетом зависимостей.
	Для Каждого КлючИЗначение Из ОписанияПодсистем.ПоИменам Цикл
		Имя = КлючИЗначение.Ключ;
		Порядок = ОписанияПодсистем.Порядок.Найти(Имя);
		Для каждого ТребуемаяПодсистема Из КлючИЗначение.Значение.ТребуемыеПодсистемы Цикл
			ПорядокТребуемойПодсистемы = ОписанияПодсистем.Порядок.Найти(ТребуемаяПодсистема);
			Если Порядок < ПорядокТребуемойПодсистемы Тогда
				Взаимозависимость = ОписанияПодсистем.ПоИменам[ТребуемаяПодсистема
					].ТребуемыеПодсистемы.Найти(Имя) <> Неопределено;
				Если Взаимозависимость Тогда
					НовыйПорядок = ПорядокТребуемойПодсистемы;
				Иначе
					НовыйПорядок = ПорядокТребуемойПодсистемы + 1;
				КонецЕсли;
				Если Порядок <> НовыйПорядок Тогда
					ОписанияПодсистем.Порядок.Вставить(НовыйПорядок, Имя);
					ОписанияПодсистем.Порядок.Удалить(Порядок);
					Порядок = НовыйПорядок - 1;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	// Смещение описания конфигурации в конец массива.
	Индекс = ОписанияПодсистем.Порядок.Найти(Метаданные.Имя);
	Если ОписанияПодсистем.Порядок.Количество() > Индекс + 1 Тогда
		ОписанияПодсистем.Порядок.Удалить(Индекс);
		ОписанияПодсистем.Порядок.Добавить(Метаданные.Имя);
	КонецЕсли;

	Для Каждого КлючИЗначение Из ОписанияПодсистем.ПоИменам Цикл
		КлючИЗначение.Значение.ТребуемыеПодсистемы =
			Новый ФиксированныйМассив(КлючИЗначение.Значение.ТребуемыеПодсистемы);

		ОписанияПодсистем.ПоИменам[КлючИЗначение.Ключ] =
			Новый ФиксированнаяСтруктура(КлючИЗначение.Значение);
	КонецЦикла;

	Возврат БазоваяПодсистемаСервер.ОН_ФиксированныеДанные(ОписанияПодсистем);
КонецФункции

Функция СП_ОписаниеТипаВсеСсылки() Экспорт
	Возврат Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(
		Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(
			Справочники.ТипВсеСсылки(),
			Документы.ТипВсеСсылки().Типы()),
			ПланыОбмена.ТипВсеСсылки().Типы()),
			Перечисления.ТипВсеСсылки().Типы()),
			ПланыВидовХарактеристик.ТипВсеСсылки().Типы()),
			ПланыСчетов.ТипВсеСсылки().Типы()),
			ПланыВидовРасчета.ТипВсеСсылки().Типы()),
			БизнесПроцессы.ТипВсеСсылки().Типы()),
			БизнесПроцессы.ТипВсеСсылкиТочекМаршрутаБизнесПроцессов().Типы()),
			Задачи.ТипВсеСсылки().Типы());
КонецФункции

Функция СП_ИменаПодсистем() Экспорт
	ОтключенныеПодсистемы	= Новый Соответствие;

	Имена					= Новый Соответствие;
	СП_ВставитьИменаПодчиненныхПодсистем(Имена, Метаданные, ОтключенныеПодсистемы);

	Возврат Новый ФиксированноеСоответствие(Имена);
КонецФункции

Процедура СП_ВставитьИменаПодчиненныхПодсистем(Имена, РодительскаяПодсистема, ОтключенныеПодсистемы, ИмяРодительскойПодсистемы = "")
	Для Каждого ТекущаяПодсистема Из РодительскаяПодсистема.Подсистемы Цикл
		Если ТекущаяПодсистема.ВключатьВКомандныйИнтерфейс Тогда
			Продолжить;
		КонецЕсли;

		ИмяТекущейПодсистемы = ИмяРодительскойПодсистемы + ТекущаяПодсистема.Имя;
		Если ОтключенныеПодсистемы.Получить(ИмяТекущейПодсистемы) = Истина Тогда
			Продолжить;
		Иначе
			Имена.Вставить(ИмяТекущейПодсистемы, Истина);
		КонецЕсли;

		Если ТекущаяПодсистема.Подсистемы.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;

		СП_ВставитьИменаПодчиненныхПодсистем(Имена, ТекущаяПодсистема, ОтключенныеПодсистемы, ИмяТекущейПодсистемы + ".");
	КонецЦикла;
КонецПроцедуры

Функция СП_СсылкиПоИменамПредопределенных(ПолноеИмяОбъектаМетаданных) Экспорт
	ПредопределенныеЗначения = Новый Соответствие;

	МетаданныеОбъекта = Метаданные.НайтиПоПолномуИмени(ПолноеИмяОбъектаМетаданных);

	// Если метаданных не существует.
	Если МетаданныеОбъекта = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	// Если не подходящий тип метаданных.
	Если Не Метаданные.Справочники.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыВидовХарактеристик.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыСчетов.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыВидовРасчета.Содержит(МетаданныеОбъекта) Тогда

		Возврат Неопределено;
	КонецЕсли;

	ИменаПредопределенных = МетаданныеОбъекта.ПолучитьИменаПредопределенных();

	// Если предопределенных у метаданного нет.
	Если ИменаПредопределенных.Количество() = 0 Тогда
		Возврат Новый ФиксированноеСоответствие(ПредопределенныеЗначения);
	КонецЕсли;

	// Заполнение по умолчанию признаком отсутствия в ИБ (присутствующие переопределятся).
	Для каждого ИмяПредопределенного Из ИменаПредопределенных Цикл
		ПредопределенныеЗначения.Вставить(ИмяПредопределенного, Null);
	КонецЦикла;

	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ТекущаяТаблица.Ссылка КАК Ссылка,
		|	ТекущаяТаблица.ИмяПредопределенныхДанных КАК ИмяПредопределенныхДанных
		|ИЗ
		|	&ТекущаяТаблица КАК ТекущаяТаблица
		|ГДЕ
		|	ТекущаяТаблица.Предопределенный";

	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТекущаяТаблица", ПолноеИмяОбъектаМетаданных);

	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);

	Выборка = Запрос.Выполнить().Выбрать();

	УстановитьПривилегированныйРежим(Ложь);
	УстановитьОтключениеБезопасногоРежима(Ложь);

	// Заполнение присутствующих в ИБ.
	Пока Выборка.Следующий() Цикл
		ПредопределенныеЗначения.Вставить(Выборка.ИмяПредопределенныхДанных, Выборка.Ссылка);
	КонецЦикла;

	Возврат Новый ФиксированноеСоответствие(ПредопределенныеЗначения);
КонецФункции

Функция СП_ОпцииИнтерфейса() Экспорт
	ОпцииИнтерфейса = Новый Структура;

	Возврат Новый ФиксированнаяСтруктура(ОпцииИнтерфейса);
КонецФункции

Функция СП_ИспользуетсяРИБ(ФильтрПоНазначению = "") Экспорт
	Если СП_УзлыРИБ(ФильтрПоНазначению).Количество() > 0 Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции

Функция СП_УзлыРИБ(ФильтрПоНазначению = "") Экспорт
	ФильтрПоНазначению = ВРег(ФильтрПоНазначению);

	СписокУзлов = Новый СписокЗначений;

	ПланыОбменаРИБ = СП_ПланыОбменаРИБ();
	Запрос = Новый Запрос;
	Для Каждого ИмяПланаОбмена Из ПланыОбменаРИБ Цикл
		// Зарезервировано для новых подсистем

		Запрос.Текст =
		"ВЫБРАТЬ
		|	ПланОбмена.Ссылка КАК Ссылка
		|ИЗ
		|	&ИмяПланаОбмена КАК ПланОбмена
		|ГДЕ
		|	НЕ ПланОбмена.ЭтотУзел
		|	И НЕ ПланОбмена.ПометкаУдаления";
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ИмяПланаОбмена", "ПланОбмена." + ИмяПланаОбмена);
		ВыборкаУзлов = Запрос.Выполнить().Выбрать();
		Пока ВыборкаУзлов.Следующий() Цикл
			СписокУзлов.Добавить(ВыборкаУзлов.Ссылка);
		КонецЦикла;
	КонецЦикла;

	Возврат СписокУзлов;
КонецФункции

Функция СП_ПланыОбменаРИБ() Экспорт
	Результат = Новый Массив;

	Для Каждого ПланОбмена Из Метаданные.ПланыОбмена Цикл
		Если Лев(ПланОбмена.Имя, 7) = "Удалить" Тогда
			Продолжить;
		КонецЕсли;

		Если ПланОбмена.РаспределеннаяИнформационнаяБаза Тогда
			Результат.Добавить(ПланОбмена.Имя);
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;
КонецФункции

Функция СП_ЭтоФоновоеЗадание() Экспорт
	Возврат ПолучитьТекущийСеансИнформационнойБазы().ПолучитьФоновоеЗадание() <> Неопределено;
КонецФункции

Функция СП_ПривилегированныйРежимУстановленПриЗапуске() Экспорт
	УстановитьПривилегированныйРежим(Истина);

	Возврат ПараметрыСеанса.ПараметрыКлиентаНаСервере.Получить("ПривилегированныйРежимУстановленПриЗапуске") = Истина;
КонецФункции

Функция СП_КэшИдентификаторовОбъектовМетаданных(КлючДанныхПовторногоИспользования) Экспорт
	Возврат Справочники.ИдентификаторыОбъектовМетаданных.КэшИдентификаторовОбъектовМетаданных(КлючДанныхПовторногоИспользования);
КонецФункции

Функция СП_ОтключитьИдентификаторыОбъектовМетаданных() Экспорт
	ОбщиеПараметры = БазоваяПодсистемаСервер.ОН_ОбщиеПараметрыБазовойФункциональности();

	Если НЕ ОбщиеПараметры.ОтключитьИдентификаторыОбъектовМетаданных Тогда
		Возврат Ложь;
	КонецЕсли;

	ВызватьИсключение "Невозможно отключить справочник Идентификаторы объектов метаданных,
			           |если используется любая из следующих подсистем:
			           |- ВариантыОтчетов,
			           |- ДополнительныеОтчетыИОбработки,
			           |- РассылкаОтчетов,
			           |- УправлениеДоступом.";
КонецФункции

Функция СП_СвойстваКоллекцийОбъектовМетаданных(ОбъектыРасширений = Ложь) Экспорт
	Возврат Справочники.ИдентификаторыОбъектовМетаданных.СвойстваКоллекцийОбъектовМетаданных(ОбъектыРасширений);
КонецФункции

Функция СП_ТаблицаПереименованияДляТекущейВерсии() Экспорт
	Возврат Справочники.ИдентификаторыОбъектовМетаданных.ТаблицаПереименованияДляТекущейВерсии();
КонецФункции

Функция СП_ИдентификаторыОбъектовМетаданныхПроверкаИспользования(ПроверитьОбновление = Ложь, ОбъектыРасширений = Ложь) Экспорт
	Справочники.ИдентификаторыОбъектовМетаданных.ПроверкаИспользования(ОбъектыРасширений);

	Если ПроверитьОбновление Тогда
		Справочники.ИдентификаторыОбъектовМетаданных.ДанныеОбновлены(Истина, ОбъектыРасширений);
	КонецЕсли;

	Возврат Истина;
КонецФункции

Функция СП_ДоступностьОбъектовПоОпциям() Экспорт
	Параметры			= Новый Структура(БазоваяПодсистемаСерверПовтИсп.СП_ОпцииИнтерфейса());

	ДоступностьОбъектов	= Новый Соответствие;
	Для Каждого ФункциональнаяОпция Из Метаданные.ФункциональныеОпции Цикл
		Значение = -1;
		Для Каждого Элемент Из ФункциональнаяОпция.Состав Цикл
			Если Элемент.Объект = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			Если Значение = -1 Тогда
				Значение = ПолучитьФункциональнуюОпцию(ФункциональнаяОпция.Имя, Параметры);
			КонецЕсли;
			ПолноеИмя = Элемент.Объект.ПолноеИмя();
			Если Значение = Истина Тогда
				ДоступностьОбъектов.Вставить(ПолноеИмя, Истина);
			Иначе
				Если ДоступностьОбъектов[ПолноеИмя] = Неопределено Тогда
					ДоступностьОбъектов.Вставить(ПолноеИмя, Ложь);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;

	Возврат Новый ФиксированноеСоответствие(ДоступностьОбъектов);
КонецФункции

#КонецОбласти
