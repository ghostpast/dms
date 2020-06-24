///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура УстановкаПараметровСеанса(ИменаПараметровСеанса, УстановленныеПараметры) Экспорт
	Если ИменаПараметровСеанса = Неопределено
	 Или ИменаПараметровСеанса.Найти("УстановленныеРасширения") <> Неопределено Тогда

		ПараметрыСеанса.УстановленныеРасширения = УстановленныеРасширения(Истина);
		УстановленныеПараметры.Добавить("УстановленныеРасширения");
	КонецЕсли;

	Если ИменаПараметровСеанса = Неопределено
	 Или ИменаПараметровСеанса.Найти("ПодключенныеРасширения") <> Неопределено Тогда

		Расширения = РасширенияКонфигурации.Получить(, ИсточникРасширенийКонфигурации.СеансАктивные);
		ПараметрыСеанса.ПодключенныеРасширения = КонтрольныеСуммыРасширений(Расширения, "БезопасныйРежим");
		УстановленныеПараметры.Добавить("ПодключенныеРасширения");
	КонецЕсли;

	Если ИменаПараметровСеанса <> Неопределено
	   И ИменаПараметровСеанса.Найти("ВерсияРасширений") <> Неопределено Тогда

		ПараметрыСеанса.ВерсияРасширений = ВерсияРасширений();
		УстановленныеПараметры.Добавить("ВерсияРасширений");
	КонецЕсли;

	Если ИменаПараметровСеанса = Неопределено
	   И ТекущийРежимЗапуска() <> Неопределено Тогда

		ЗарегистрироватьИспользованиеВерсииРасширений();
	КонецЕсли;
КонецПроцедуры

Процедура ЗарегистрироватьИспользованиеВерсииРасширений() Экспорт
	ВерсияРасширений = ПараметрыСеанса.ВерсияРасширений;

	Если Не ЗначениеЗаполнено(ВерсияРасширений) Тогда
		Возврат;
	КонецЕсли;

	Запрос			= Новый Запрос;
	Запрос.Текст	=
	"ВЫБРАТЬ ПЕРВЫЕ 2
	|	ИСТИНА КАК ЗначениеИстина
	|ИЗ
	|	Справочник.ВерсииРасширений КАК ВерсииРасширений
	|ГДЕ
	|	НЕ ВерсииРасширений.ПометкаУдаления";

	// Если справочник изменяется в другом сеансе, тогда нужно дождаться окончания изменений.
	Блокировка				= Новый БлокировкаДанных;
	ЭлементБлокировки		= Блокировка.Добавить("Справочник.ВерсииРасширений");
	ЭлементБлокировки.Режим	= РежимБлокировкиДанных.Разделяемый;

	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		РезультатыЗапроса = Запрос.ВыполнитьПакет();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();

		ВызватьИсключение;
	КонецПопытки;

	Если РезультатыЗапроса[0].Выбрать().Количество() < 2 Тогда
		ОбновитьПоследнююВерсиюРасширений(ВерсияРасширений);

		Возврат;
	КонецЕсли;

	ТекущийСеанс = ПолучитьТекущийСеансИнформационнойБазы();
	НачалоСеанса = ТекущийСеанс.НачалоСеанса;
	НомерСеанса  = ТекущийСеанс.НомерСеанса;

	НаборЗаписей = РегистрыСведений.СеансыВерсийРасширений.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.НомерСеанса.Установить(НомерСеанса);
	НаборЗаписей.Отбор.НачалоСеанса.Установить(НачалоСеанса);
	НаборЗаписей.Отбор.ВерсияРасширений.Установить(ВерсияРасширений);

	НоваяЗапись						= НаборЗаписей.Добавить();
	НоваяЗапись.НомерСеанса			= НомерСеанса;
	НоваяЗапись.НачалоСеанса		= НачалоСеанса;
	НоваяЗапись.ВерсияРасширений	= ВерсияРасширений;

	НаборЗаписей.ОбменДанными.Загрузка = Истина;
	НаборЗаписей.Записать();

	ОбновитьПоследнююВерсиюРасширений(ВерсияРасширений);
КонецПроцедуры

Процедура ОбновитьПоследнююВерсиюРасширений(ВерсияРасширений)
	Если КонфигурацияБазыДанныхИзмененаДинамически()
	 Или РасширенияИзмененыДинамически() Тогда
		Возврат;
	КонецЕсли;

	ХранимыеСвойства = ПоследняяВерсияРасширений();

	Если ХранимыеСвойства.ВерсияРасширений = ВерсияРасширений Тогда
		Возврат;
	КонецЕсли;

	ХранимыеСвойства.ВерсияРасширений = ВерсияРасширений;
	ХранимыеСвойства.ДатаОбновления   = ТекущаяДатаСеанса();

	ИмяПараметра = "СтандартныеПодсистемы.БазоваяПодсистема.ПоследняяВерсияРасширений";
	РегистрыСведений.ПараметрыРаботыВерсийРасширений.УстановитьПараметрРаботыРасширения(ИмяПараметра, ХранимыеСвойства, Истина);

	// Зарезервировано для новых подсистем
КонецПроцедуры

Функция ПоследняяВерсияРасширений() Экспорт
	ИмяПараметра = "СтандартныеПодсистемы.БазоваяПодсистема.ПоследняяВерсияРасширений";
	ХранимыеСвойства = РегистрыСведений.ПараметрыРаботыВерсийРасширений.ПараметрРаботыРасширения(ИмяПараметра, Истина);

	Если ХранимыеСвойства = Неопределено
	 Или ТипЗнч(ХранимыеСвойства) <> Тип("Структура")
	 Или Не ХранимыеСвойства.Свойство("ВерсияРасширений")
	 Или Не ХранимыеСвойства.Свойство("ДатаОбновления") Тогда

		ХранимыеСвойства = Новый Структура("ВерсияРасширений, ДатаОбновления", , '00010101');
	КонецЕсли;

	Возврат ХранимыеСвойства;
КонецФункции

Процедура УдалитьУстаревшиеВерсииПараметров() Экспорт
	Запрос			= Новый Запрос;
	Запрос.Текст	=
	"ВЫБРАТЬ
	|	ВерсииРасширений.Ссылка КАК ВерсияРасширений,
	|	СеансыВерсийРасширений.НомерСеанса КАК НомерСеанса,
	|	СеансыВерсийРасширений.НачалоСеанса КАК НачалоСеанса
	|ИЗ
	|	Справочник.ВерсииРасширений КАК ВерсииРасширений
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СеансыВерсийРасширений КАК СеансыВерсийРасширений
	|		ПО (СеансыВерсийРасширений.ВерсияРасширений = ВерсииРасширений.Ссылка)
	|ГДЕ
	|	ВерсииРасширений.Ссылка <> &ТекущаяВерсияРасширений
	|	И НЕ ВерсииРасширений.ПометкаУдаления
	|ИТОГИ ПО
	|	ВерсияРасширений
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВерсииРасширений.Ссылка КАК ВерсияРасширений,
	|	ВерсииРасширений.ПоследняяДатаДобавленияВторойВерсии КАК ПоследняяДатаДобавленияВторойВерсии
	|ИЗ
	|	Справочник.ВерсииРасширений КАК ВерсииРасширений
	|ГДЕ
	|	ВерсииРасширений.ПоследняяДатаДобавленияВторойВерсии <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|	И НЕ ВерсииРасширений.ПометкаУдаления
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВерсииРасширений.Ссылка КАК ВерсияРасширений,
	|	ВерсииРасширений.ДатаПервогоВходаПослеУдаленияВсехРасширений КАК ДатаПервогоВходаПослеУдаленияВсехРасширений
	|ИЗ
	|	Справочник.ВерсииРасширений КАК ВерсииРасширений
	|ГДЕ
	|	ВерсииРасширений.ДатаПервогоВходаПослеУдаленияВсехРасширений <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|	И НЕ ВерсииРасширений.ПометкаУдаления";
	Запрос.УстановитьПараметр("ТекущаяВерсияРасширений", ПараметрыСеанса.ВерсияРасширений);

	// Если справочник ВерсииРасширений или регистр сведений СеансыВерсийРасширений изменяются в другом сеансе,
	// тогда нужно дождаться окончания изменений.
	Блокировка				= Новый БлокировкаДанных;
	ЭлементБлокировки		= Блокировка.Добавить("Справочник.ВерсииРасширений");
	ЭлементБлокировки.Режим	= РежимБлокировкиДанных.Разделяемый;
	ЭлементБлокировки		= Блокировка.Добавить("РегистрСведений.СеансыВерсийРасширений");
	ЭлементБлокировки.Режим	= РежимБлокировкиДанных.Разделяемый;

	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		РезультатыЗапроса = Запрос.ВыполнитьПакет();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;

	Выгрузка = РезультатыЗапроса[0].Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);

	МассивСеансов = ПолучитьСеансыИнформационнойБазы();

	// Версия, которая была первой при очередном добавлении второй версии
	// (в самом начале или после удаления устаревших версий) может
	// использоваться сеансами, которые были открыты до этого события.
	ВерсияИспользуемаяВНезарегистрированныхСеансах				= Неопределено;
	ДатаОкончанияСеансовИспользующихРасширенияБезРегистрации	= '00010101';

	Если ЗначениеЗаполнено(ПараметрыСеанса.УстановленныеРасширения.Основные)  Или ЗначениеЗаполнено(ПараметрыСеанса.УстановленныеРасширения.Исправления) Тогда
		Если Не РезультатыЗапроса[1].Пустой() Тогда
			Свойства													= РезультатыЗапроса[1].Выгрузить()[0];
			ДатаОкончанияСеансовИспользующихРасширенияБезРегистрации	= Свойства.ПоследняяДатаДобавленияВторойВерсии;
			ПерваяВерсия												= Свойства.ВерсияРасширений;
		КонецЕсли;
	Иначе
		Если Не РезультатыЗапроса[2].Пустой() Тогда
			Свойства													= РезультатыЗапроса[2].Выгрузить()[0];
			ДатаОкончанияСеансовИспользующихРасширенияБезРегистрации	= Свойства.ДатаПервогоВходаПослеУдаленияВсехРасширений;
			ПерваяВерсия												= Свойства.ВерсияРасширений;
		КонецЕсли;
	КонецЕсли;

	ПроверяемыеПриложения = Новый Соответствие;
	ПроверяемыеПриложения.Вставить("1CV8",					Истина);
	ПроверяемыеПриложения.Вставить("1CV8C",					Истина);
	ПроверяемыеПриложения.Вставить("WebClient",				Истина);
	ПроверяемыеПриложения.Вставить("COMConnection",			Истина);
	ПроверяемыеПриложения.Вставить("WSConnection",			Истина);
	ПроверяемыеПриложения.Вставить("BackgroundJob",			Истина);
	ПроверяемыеПриложения.Вставить("SystemBackgroundJob",	Истина);

	Сеансы = Новый Соответствие;
	Для Каждого Сеанс Из МассивСеансов Цикл
		Если ПроверяемыеПриложения.Получить(Сеанс.ИмяПриложения) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Сеансы.Вставить(Сеанс.НомерСеанса, Сеанс.НачалоСеанса);
		Если Сеанс.НачалоСеанса < ДатаОкончанияСеансовИспользующихРасширенияБезРегистрации Тогда
			ВерсияИспользуемаяВНезарегистрированныхСеансах = ПерваяВерсия;
		КонецЕсли;
	КонецЦикла;

	// Удаление устаревших версий метаданных.
	ВерсииУдалялись = Ложь;
	Для Каждого ОписаниеВерсии Из Выгрузка.Строки Цикл
		ВерсияИспользуется = Ложь;
		Для Каждого Строка Из ОписаниеВерсии.Строки Цикл
			Если СеансСуществует(Строка, Сеансы) Тогда
				ВерсияИспользуется = Истина;

				Прервать;
			КонецЕсли;
		КонецЦикла;
		ТекущаяВерсия = ОписаниеВерсии.ВерсияРасширений;
		Если ВерсияИспользуется
		 Или ТекущаяВерсия = ВерсияИспользуемаяВНезарегистрированныхСеансах Тогда
			Продолжить;
		КонецЕсли;

		Блокировка			= Новый БлокировкаДанных;
		ЭлементБлокировки	= Блокировка.Добавить("Справочник.ВерсииРасширений");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", ТекущаяВерсия);

		НачатьТранзакцию();
		Попытка
			Блокировка.Заблокировать();
			Объект					= ТекущаяВерсия.ПолучитьОбъект();
			Объект.ПометкаУдаления	= Истина;
			ОбновлениеВерсииИБСервер.ОИБ_ЗаписатьДанные(Объект);
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;

		ВерсииУдалялись = Истина;
	КонецЦикла;

	// Отключение регламентного задания, если осталась только одна версия расширений.

	// Достаточно полной разделяемой блокировки справочника ВерсииРасширений и
	// регистра сведений СеансыВерсийРасширений (исключительную ставить избыточно и
	// крайне плохо, так как это задержит вход в другие сеансы).
	// Взаимоблокировки исключены использованием разделяемых блокировок на всю таблицу в целом,
	// что допустимо и необходимо для механизма регистрации использования версий.
	Блокировка				= Новый БлокировкаДанных;
	ЭлементБлокировки		= Блокировка.Добавить("Справочник.ВерсииРасширений");
	ЭлементБлокировки.Режим	= РежимБлокировкиДанных.Разделяемый;

	Запрос			= Новый Запрос;
	Запрос.Текст	=
	"ВЫБРАТЬ ПЕРВЫЕ 2
	|	ВерсииРасширений.Ссылка КАК Ссылка,
	|	ВерсииРасширений.ДатаПервогоВходаПослеУдаленияВсехРасширений КАК ДатаПервогоВходаПослеУдаленияВсехРасширений
	|ИЗ
	|	Справочник.ВерсииРасширений КАК ВерсииРасширений
	|ГДЕ
	|	НЕ ВерсииРасширений.ПометкаУдаления";

	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		Выгрузка = Запрос.Выполнить().Выгрузить();
		Если Выгрузка.Количество() < 2 Тогда
			Если Выгрузка.Количество() = 0 Тогда
				ВключитьЗаданиеУдалениеУстаревшихПараметровРаботыВерсийРасширений(Ложь);
			Иначе
				// Удаление всех регистраций использования метаданных.
				ВсеЗаписи = РегистрыСведений.СеансыВерсийРасширений.СоздатьНаборЗаписей();
				ВсеЗаписи.Записать();

				Если ЗначениеЗаполнено(ПараметрыСеанса.УстановленныеРасширения.Основные) Или ЗначениеЗаполнено(ПараметрыСеанса.УстановленныеРасширения.Исправления) Тогда
					ВключитьЗаданиеУдалениеУстаревшихПараметровРаботыВерсийРасширений(Ложь);
				КонецЕсли;
				Если ВерсииУдалялись И ЗначениеЗаполнено(Выгрузка[0].ДатаПервогоВходаПослеУдаленияВсехРасширений) Тогда
					Объект												= Выгрузка[0].Ссылка.ПолучитьОбъект();
					Объект.ДатаПервогоВходаПослеУдаленияВсехРасширений	= Неопределено;
					Объект.Записать();
				КонецЕсли;
			КонецЕсли;
		Иначе
			// Удаление устаревших регистраций использования метаданных.
			ВсеЗаписи = РегистрыСведений.СеансыВерсийРасширений.СоздатьНаборЗаписей();
			ВсеЗаписи.Прочитать();

			Для Каждого Строка Из ВсеЗаписи Цикл
				Если СеансСуществует(Строка, Сеансы) Тогда
					Продолжить;
				КонецЕсли;
				НаборЗаписей = РегистрыСведений.СеансыВерсийРасширений.СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.НомерСеанса.Установить(Строка.НомерСеанса);
				НаборЗаписей.Отбор.НачалоСеанса.Установить(Строка.НачалоСеанса);
				НаборЗаписей.Отбор.ВерсияРасширений.Установить(Строка.ВерсияРасширений);
				НаборЗаписей.Записать();
			КонецЦикла;
		КонецЕсли;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();

		ВызватьИсключение;
	КонецПопытки;
КонецПроцедуры

Функция УстановленныеРасширения(ПриЗапуске = Ложь) Экспорт
	РасширенияБазыДанных = РасширенияКонфигурации.Получить();
	Если ПриЗапуске Тогда
		РасширенияПриЗапуске	= Новый Соответствие;
		АктивныеРасширения		= РасширенияКонфигурации.Получить(, ИсточникРасширенийКонфигурации.СеансАктивные);
		Для Каждого Расширение Из АктивныеРасширения Цикл
			РасширенияПриЗапуске.Вставить(КонтрольнаяСуммаРасширения(Расширение), Расширение);
		КонецЦикла;
		НеподключенныеРасширения = РасширенияКонфигурации.Получить(, ИсточникРасширенийКонфигурации.СеансОтключенные);
		Для Каждого Расширение Из НеподключенныеРасширения Цикл
			РасширенияПриЗапуске.Вставить(КонтрольнаяСуммаРасширения(Расширение), Расширение);
		КонецЦикла;
		ДобавленныеРасширения	= Новый Соответствие;
		Расширения				= Новый Массив;
		Для Каждого Расширение Из РасширенияБазыДанных Цикл
			КонтрольнаяСумма		= КонтрольнаяСуммаРасширения(Расширение);
			РасширениеПриЗапуске	= РасширенияПриЗапуске.Получить(КонтрольнаяСумма);
			Если РасширениеПриЗапуске <> Неопределено Тогда
				ДобавленныеРасширения.Вставить(КонтрольнаяСумма, Истина);
				Расширения.Добавить(РасширениеПриЗапуске);
			КонецЕсли;
		КонецЦикла;
		Для Каждого ОписаниеРасширения Из РасширенияПриЗапуске Цикл
			Если ДобавленныеРасширения.Получить(ОписаниеРасширения.Ключ) = Неопределено Тогда
				Расширения.Добавить(ОписаниеРасширения.Значение);
			КонецЕсли;
		КонецЦикла;
	Иначе
		Расширения = РасширенияБазыДанных;
	КонецЕсли;

	Основные    = Новый Массив;
	Исправления = Новый Массив;

	// Зарезервировано для новых подсистем

	Для Каждого Расширение Из Расширения Цикл
		// Зарезервировано для новых подсистем

		Основные.Добавить(Расширение);
	КонецЦикла;

	УстановленныеРасширения = Новый Структура;
	УстановленныеРасширения.Вставить("Основные",				КонтрольныеСуммыРасширений(Основные));
	УстановленныеРасширения.Вставить("Исправления",				КонтрольныеСуммыРасширений(Исправления));
	УстановленныеРасширения.Вставить("ОсновныеСостояние",		КонтрольныеСуммыРасширений(Основные, "Все"));
	УстановленныеРасширения.Вставить("ИсправленияСостояние",	КонтрольныеСуммыРасширений(Исправления, "Все"));

	Возврат Новый ФиксированнаяСтруктура(УстановленныеРасширения);
КонецФункции

Процедура ВключитьЗаданиеУдалениеУстаревшихПараметровРаботыВерсийРасширений(Включить) Экспорт
	РегламентныеЗаданияСервер.РЗ_УстановитьИспользованиеПредопределенногоРегламентногоЗадания(
		Метаданные.РегламентныеЗадания.УдалениеУстаревшихПараметровРаботыВерсийРасширений, Включить);
КонецПроцедуры

Функция РасширенияИзмененыДинамически() Экспорт
	УстановитьПривилегированныйРежим(Истина);

	УстановленныеРасширения = УстановленныеРасширения();

	Возврат ПараметрыСеанса.УстановленныеРасширения.ОсновныеСостояние <> УстановленныеРасширения.ОсновныеСостояние
	    Или ПараметрыСеанса.УстановленныеРасширения.ИсправленияСостояние <> УстановленныеРасширения.ИсправленияСостояние;
КонецФункции

Функция КонтрольныеСуммыРасширений(Расширения, СвойстваПодключения = "")
	Список = Новый СписокЗначений;

	Для Каждого Расширение Из Расширения Цикл
		Список.Добавить(КонтрольнаяСуммаРасширения(Расширение, СвойстваПодключения));
	КонецЦикла;

	Если Список.Количество() <> 0 Тогда
		КонтрольнаяСумма = "#" + Метаданные.Имя + " (" + Метаданные.Версия + ")";
		Список.Добавить(КонтрольнаяСумма);
	КонецЕсли;

	КонтрольныеСуммы = "";
	Для Каждого Элемент Из Список Цикл
		КонтрольныеСуммы = КонтрольныеСуммы + Символы.ПС + Элемент.Значение;
	КонецЦикла;

	Возврат СокрЛ(КонтрольныеСуммы);
КонецФункции

Функция КонтрольнаяСуммаРасширения(Расширение, СвойстваПодключения = "")
	КонтрольнаяСумма = Расширение.Имя + " (" + Расширение.Версия + ") " + Base64Строка(Расширение.ХешСумма);

	Если ЗначениеЗаполнено(СвойстваПодключения) Тогда
		КонтрольнаяСумма = КонтрольнаяСумма + " БезопасныйРежим:" + Расширение.БезопасныйРежим;
	КонецЕсли;

	Если СвойстваПодключения = "Все" Тогда
		КонтрольнаяСумма = КонтрольнаяСумма
			+ " ПередаватьВПодчиненныеУзлыРИБ:" + Расширение.ИспользуетсяВРаспределеннойИнформационнойБазе
			+ " Активно:" + Расширение.Активно;
	КонецЕсли;

	Возврат КонтрольнаяСумма;
КонецФункции

Функция ВерсияРасширений()
	Если Не ЗначениеЗаполнено(ПараметрыСеанса.УстановленныеРасширения.Основные)
	   И Не ЗначениеЗаполнено(ПараметрыСеанса.УстановленныеРасширения.Исправления) Тогда

		ЗарегистрироватьПервыйВходПослеУдаленияВсехРасширений();
	КонецЕсли;

	ОписаниеРасширений = ПараметрыСеанса.ПодключенныеРасширения;
	Если Не ЗначениеЗаполнено(ОписаниеРасширений) Тогда
		Возврат ПустаяСсылка();
	КонецЕсли;

	Запрос			= Новый Запрос;
	Запрос.Текст	=
	"ВЫБРАТЬ
	|	ВерсииРасширений.Ссылка КАК Ссылка,
	|	ВерсииРасширений.ОписаниеМетаданных КАК ОписаниеРасширений
	|ИЗ
	|	Справочник.ВерсииРасширений КАК ВерсииРасширений
	|ГДЕ
	|	НЕ ВерсииРасширений.ПометкаУдаления";

	// Если справочник изменяется в другом сеансе, тогда нужно дождаться окончания изменений.
	Блокировка				= Новый БлокировкаДанных;
	ЭлементБлокировки		= Блокировка.Добавить("Справочник.ВерсииРасширений");
	ЭлементБлокировки.Режим	= РежимБлокировкиДанных.Разделяемый;
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		Выборка = Запрос.Выполнить().Выбрать();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();

		ВызватьИсключение;
	КонецПопытки;

	Если ВерсияНайдена(Выборка, ОписаниеРасширений) Тогда
		ВерсияРасширений = Выборка.Ссылка;
	Иначе
		// Создание новой версии расширений.
		Блокировка			= Новый БлокировкаДанных;
		ЭлементБлокировки	= Блокировка.Добавить("Справочник.ВерсииРасширений");
		НачатьТранзакцию();
		Попытка
			// Повторная проверка, что версия еще не создана,
			// что маловероятно, но возможно между транзакциями.
			// Сразу исключительная блокировка недопустима, так как это
			// замедлит вход пользователей в другие сеансы.
			Выборка = Запрос.Выполнить().Выбрать();
			Если ВерсияНайдена(Выборка, ОписаниеРасширений) Тогда
				ВерсияРасширений = Выборка.Ссылка;
			Иначе
				Блокировка.Заблокировать();
				Запрос			= Новый Запрос;
				Запрос.Текст	=
				"ВЫБРАТЬ
				|	ВерсииРасширений.Ссылка КАК Ссылка
				|ИЗ
				|	Справочник.ВерсииРасширений КАК ВерсииРасширений
				|ГДЕ
				|	НЕ ВерсииРасширений.ПометкаУдаления";
				Выборка = Запрос.Выполнить().Выбрать();
				Если Выборка.Следующий() И Выборка.Количество() = 1 Тогда
					Объект = Выборка.Ссылка.ПолучитьОбъект();
					// АПК:143-выкл - №643.2.1 Требуется ТекущаяДата сервера, а не ТекущаяДатаСеанса,
					// так как именно ТекущаяДата устанавливается в поле НачалоСеанса.
					Объект.ПоследняяДатаДобавленияВторойВерсии = ТекущаяДата();
					// АПК:143-вкл.
					Объект.ОбменДанными.Загрузка = Истина;
					Объект.Записать();
					ВключитьЗаданиеУдалениеУстаревшихПараметровРаботыВерсийРасширений(Истина);
				КонецЕсли;
				Объект							= СоздатьЭлемент();
				Объект.ОписаниеМетаданных		= ОписаниеРасширений;
				Объект.ОбменДанными.Загрузка	= Истина;
				Объект.Записать();
				ВерсияРасширений				= Объект.Ссылка;
			КонецЕсли;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();

			ВызватьИсключение;
		КонецПопытки;
	КонецЕсли;

	Возврат ВерсияРасширений;
КонецФункции

Процедура ЗарегистрироватьПервыйВходПослеУдаленияВсехРасширений()
	Запрос			= Новый Запрос;
	Запрос.Текст	=
	"ВЫБРАТЬ ПЕРВЫЕ 2
	|	ВерсииРасширений.Ссылка КАК Ссылка,
	|	ВерсииРасширений.ДатаПервогоВходаПослеУдаленияВсехРасширений КАК ДатаПервогоВходаПослеУдаленияВсехРасширений
	|ИЗ
	|	Справочник.ВерсииРасширений КАК ВерсииРасширений
	|ГДЕ
	|	НЕ ВерсииРасширений.ПометкаУдаления";
	Выгрузка = Запрос.Выполнить().Выгрузить();

	Если Выгрузка.Количество() = 1
	   И Не ЗначениеЗаполнено(Выгрузка[0].ДатаПервогоВходаПослеУдаленияВсехРасширений) Тогда

		ВерсияРасширенийСсылка = Выгрузка[0].Ссылка; // СправочникСсылка.ВерсииРасширений
		НачатьТранзакцию();
		Попытка
			Блокировка			= Новый БлокировкаДанных;
			ЭлементБлокировки	= Блокировка.Добавить("Справочник.ВерсииРасширений");
			ЭлементБлокировки.УстановитьЗначение("Ссылка", ВерсияРасширенийСсылка);
			Блокировка.Заблокировать();

			Объект = ВерсияРасширенийСсылка.ПолучитьОбъект();
			Если Не ЗначениеЗаполнено(Объект.ДатаПервогоВходаПослеУдаленияВсехРасширений) Тогда
				// АПК:143-выкл. См. 643.2.1. Требуется ТекущаяДата сервера, а не ТекущаяДатаСеанса,
				// так как именно ТекущаяДата устанавливается в поле НачалоСеанса.
				Объект.ДатаПервогоВходаПослеУдаленияВсехРасширений = ТекущаяДата();
				// АПК:143-вкл.
				Объект.Записать();
			КонецЕсли;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();

			ВызватьИсключение;
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры

Функция ВерсияНайдена(Выборка, ОписаниеРасширений)
	Пока Выборка.Следующий() Цикл
		Если Выборка.ОписаниеРасширений = ОписаниеРасширений Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;
КонецФункции

Функция СеансСуществует(ОписаниеСеанса, СуществующиеСеансы)
	НачалоСеанса = СуществующиеСеансы[ОписаниеСеанса.НомерСеанса];

	Возврат НачалоСеанса <> Неопределено И НачалоСеанса > (ОписаниеСеанса.НачалоСеанса - 30) И (ОписаниеСеанса.НачалоСеанса + 30) > НачалоСеанса;
КонецФункции

#КонецЕсли
