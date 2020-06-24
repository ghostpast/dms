///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Перем СтарыйРодитель; // Значение родителя группы до изменения для использования
                      // в обработчике события ПриЗаписи.

Перем СтарыйСоставГруппыПользователей; // Состав пользователей группы пользователей
                                       // до изменения для использования в обработчике
                                       // события ПриЗаписи.

Перем ЭтоНовый; // Показывает, что был записан новый объект.
                // Используются в обработчике события ПриЗаписи.

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	ПроверенныеРеквизитыОбъекта	= Новый Массив;
	Ошибки						= Неопределено;

	// Проверка использования родителя.
	Если Родитель = Справочники.ГруппыПользователей.ВсеПользователи Тогда
		БазоваяПодсистемаКлиентСервер.ОН_ДобавитьОшибкуПользователю(Ошибки, "Объект.Родитель", "Предопределенная группа ""Все пользователи"" не может быть родителем.", "");
	КонецЕсли;

	// Проверка незаполненных и повторяющихся пользователей.
	ПроверенныеРеквизитыОбъекта.Добавить("Состав.Пользователь");

	Для каждого ТекущаяСтрока Из Состав Цикл;
		НомерСтроки = Состав.Индекс(ТекущаяСтрока);

		// Проверка заполнения значения.
		Если НЕ ЗначениеЗаполнено(ТекущаяСтрока.Пользователь) Тогда
			БазоваяПодсистемаКлиентСервер.ОН_ДобавитьОшибкуПользователю(Ошибки,  "Объект.Состав[%1].Пользователь", "Пользователь не выбран.", "Объект.Состав", НомерСтроки, "Пользователь в строке %1 не выбран.");

			Продолжить;
		КонецЕсли;

		// Проверка наличия повторяющихся значений.
		НайденныеЗначения = Состав.НайтиСтроки(Новый Структура("Пользователь", ТекущаяСтрока.Пользователь));
		Если НайденныеЗначения.Количество() > 1 Тогда
			БазоваяПодсистемаКлиентСервер.ОН_ДобавитьОшибкуПользователю(Ошибки, "Объект.Состав[%1].Пользователь", "Пользователь повторяется.", "Объект.Состав", НомерСтроки, "Пользователь в строке %1 повторяется.");
		КонецЕсли;
	КонецЦикла;

	БазоваяПодсистемаКлиентСервер.ОН_СообщитьОшибкиПользователю(Ошибки, Отказ);

	БазоваяПодсистемаСервер.ОН_УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, ПроверенныеРеквизитыОбъекта);
КонецПроцедуры

// Блокирует недопустимые действия с предопределенной группой "Все пользователи".
Процедура ПередЗаписью(Отказ)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	ЭтоНовый = ЭтоНовый();

	Если Ссылка = Справочники.ГруппыПользователей.ВсеПользователи Тогда
		Если НЕ Родитель.Пустая() Тогда
			ВызватьИсключение "Предопределенная группа ""Все пользователи""
				           |может быть только в корне.";
		КонецЕсли;
		Если Состав.Количество() > 0 Тогда
			ВызватьИсключение "Добавление пользователей в группу
				           |""Все пользователи"" не поддерживается.";
		КонецЕсли;
	Иначе
		Если Родитель = Справочники.ГруппыПользователей.ВсеПользователи Тогда
			ВызватьИсключение "Предопределенная группа ""Все пользователи""
				           |не может быть родителем.";
		КонецЕсли;

		СтарыйРодитель = ?(Ссылка.Пустая(), Неопределено, БазоваяПодсистемаСервер.ОН_ЗначениеРеквизитаОбъекта(Ссылка, "Родитель"));

		Если ЗначениеЗаполнено(Ссылка) И Ссылка <> Справочники.ГруппыПользователей.ВсеПользователи Тогда
			СтарыйСоставГруппыПользователей = БазоваяПодсистемаСервер.ОН_ЗначениеРеквизитаОбъекта(Ссылка, "Состав").Выгрузить();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	УчастникиИзменений = Новый Соответствие;
	ИзмененныеГруппы   = Новый Соответствие;

	Если Ссылка <> Справочники.ГруппыПользователей.ВсеПользователи Тогда
		ИзмененияСостава = ПользователиСервер.сП_РазличияЗначенийКолонки("Пользователь", Состав.Выгрузить(), СтарыйСоставГруппыПользователей);

		ПользователиСервер.сП_ОбновитьСоставыГруппПользователей(Ссылка, ИзмененияСостава, УчастникиИзменений, ИзмененныеГруппы);

		Если СтарыйРодитель <> Родитель Тогда
			Если ЗначениеЗаполнено(Родитель) Тогда
				ПользователиСервер.сП_ОбновитьСоставыГруппПользователей(Родитель, , УчастникиИзменений, ИзмененныеГруппы);
			КонецЕсли;

			Если ЗначениеЗаполнено(СтарыйРодитель) Тогда
				ПользователиСервер.сП_ОбновитьСоставыГруппПользователей(СтарыйРодитель, , УчастникиИзменений, ИзмененныеГруппы);
			КонецЕсли;
		КонецЕсли;

		ПользователиСервер.сП_ОбновитьИспользуемостьСоставовГруппПользователей(Ссылка, УчастникиИзменений, ИзмененныеГруппы);

		Если Не ПользователиСервер.П_ЭтоПолноправныйПользователь() Тогда
			ПроверитьПравоИзмененияСостава(ИзмененияСостава);
		КонецЕсли;
	КонецЕсли;

	ПользователиСервер.сП_ПослеОбновленияСоставовГруппПользователей(УчастникиИзменений, ИзмененныеГруппы);

	ИнтеграцияПодсистемСервер.ПослеДобавленияИзмененияПользователяИлиГруппы(Ссылка, ЭтоНовый);
КонецПроцедуры

Процедура ПроверитьПравоИзмененияСостава(ИзмененияСостава)
	Запрос			= Новый Запрос;
	Запрос.Текст	=
	"ВЫБРАТЬ
	|	Пользователи.Наименование КАК Наименование
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.Ссылка В(&Пользователи)
	|	И НЕ Пользователи.Подготовлен";
	Запрос.УстановитьПараметр("Пользователи", ИзмененияСостава);

	РезультатЗапроса = Запрос.Выполнить();

	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;

	ТекстОшибки = "Недостаточно прав доступа.
		           |
		           |В состав участников групп пользователей можно добавлять и удалять только
		           |новых (добавленных) пользователей, у которых включен признак Подготовлен.
		           |
		           |Запрещено добавлять и удалять существующих пользователей:";

	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		ТекстОшибки = ТекстОшибки + Символы.ПС + Выборка.Наименование;
	КонецЦикла;

	ВызватьИсключение ТекстОшибки;
КонецПроцедуры

#Иначе
ВызватьИсключение "Недопустимый вызов объекта на клиенте.";
#КонецЕсли
