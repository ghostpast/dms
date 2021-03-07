///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	РедактируемыйСписок = Параметры.РедактируемыйСписок;
	ОтбираемыеПараметры = Параметры.ОтбираемыеПараметры;

	УстановитьПараметрыРедактора(РедактируемыйСписок, ОтбираемыеПараметры);
КонецПроцедуры

&НаКлиенте
Процедура ПометкаПриИзменении(Элемент)
	ОтметитьЭлементДерева(Элементы.Список.ТекущиеДанные, Элементы.Список.ТекущиеДанные.Пометка);
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьСоставОтбора(Команда)
	Оповестить("ВыборЗначенийЭлементовОтбораЖурналаРегистрации", ПолучитьОтредактированныйСписок(), ВладелецФормы);
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсеФлажки()
	УстановкаПометок(Истина);
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсеФлажки()
	УстановкаПометок(Ложь);
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрыРедактора(РедактируемыйСписок, ОтбираемыеПараметры)
	СтруктураПараметровОтбора	= ПолучитьЗначенияОтбораЖурналаРегистрации(ОтбираемыеПараметры);
	ЗначенияОтбора				= СтруктураПараметровОтбора[ОтбираемыеПараметры];
	// Получение списка представлений событий.
	Если ОтбираемыеПараметры = "Событие" Или ОтбираемыеПараметры = "Event" Тогда
		Для Каждого ЭлементСоответствия Из ЗначенияОтбора Цикл
			СтрокаПредставленияСобытий					= ПредставленияСобытий.Добавить();
			СтрокаПредставленияСобытий.Представление	= ЭлементСоответствия.Значение;
		КонецЦикла;
	КонецЕсли;

	Если ТипЗнч(ЗначенияОтбора) = Тип("Массив") Тогда
		ЭлементыСписка = Список.ПолучитьЭлементы();
		Для Каждого ЭлементМассива Из ЗначенияОтбора Цикл
			НовыйЭлемент				= ЭлементыСписка.Добавить();
			НовыйЭлемент.Пометка		= Ложь;
			НовыйЭлемент.Значение		= ЭлементМассива;
			НовыйЭлемент.Представление	= ЭлементМассива;
		КонецЦикла;
	ИначеЕсли ТипЗнч(ЗначенияОтбора) = Тип("Соответствие") Тогда
		Если ОтбираемыеПараметры = "Событие" Или ОтбираемыеПараметры = "Event" Или ОтбираемыеПараметры = "Метаданные" Или ОтбираемыеПараметры = "Metadata" Тогда
			// Грузим как дерево
			Для Каждого ЭлементСоответствия Из ЗначенияОтбора Цикл
				НовыйЭлемент			= ПолучитьВетвьДерева(ЭлементСоответствия.Значение, ОтбираемыеПараметры);
				НовыйЭлемент.Пометка	= Ложь;
				Если ПустаяСтрока(НовыйЭлемент.Значение) Тогда
					НовыйЭлемент.Значение = ЭлементСоответствия.Ключ;
				Иначе
					НовыйЭлемент.Значение = НовыйЭлемент.Значение + Символы.ПС + ЭлементСоответствия.Ключ;
				КонецЕсли;
				НовыйЭлемент.ПолноеПредставление = ЭлементСоответствия.Значение;
			КонецЦикла;
		Иначе
			// Грузим плоским списком
			ЭлементыСписка = Список.ПолучитьЭлементы();
			Для Каждого ЭлементСоответствия Из ЗначенияОтбора Цикл
				НовыйЭлемент			= ЭлементыСписка.Добавить();
				НовыйЭлемент.Пометка	= Ложь;
				НовыйЭлемент.Значение	= ЭлементСоответствия.Ключ;

				Если (ОтбираемыеПараметры = "Пользователь" Или ОтбираемыеПараметры = "User") Тогда
					// Для пользователей ключом служит имя.
					НовыйЭлемент.Значение				= ЭлементСоответствия.Значение;
					НовыйЭлемент.Представление			= ЭлементСоответствия.Значение;
					НовыйЭлемент.ПолноеПредставление	= ЭлементСоответствия.Значение;

					Если НовыйЭлемент.Значение = "" Тогда
						// Случай для пользователя по умолчанию.
						НовыйЭлемент.Значение				= "";
						НовыйЭлемент.ПолноеПредставление	= "<Не указан>";
						НовыйЭлемент.Представление			= "<Не указан>";
					КонецЕсли;
				Иначе
					НовыйЭлемент.Представление			= ЭлементСоответствия.Значение;
					НовыйЭлемент.ПолноеПредставление	= ЭлементСоответствия.Значение;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;

	// Помечаем элементы дерева, если им есть соответствие в РедактируемыйСписок.
	ОтметитьВстречающиесяЭлементы(Список.ПолучитьЭлементы(), РедактируемыйСписок);

	// Проверяем список на наличие подчиненных элементов, если их нет,
	// переводим ЭУ в режим Списка.
	ЭтоДерево = Ложь;
	Для Каждого ЭлементДерева Из Список.ПолучитьЭлементы() Цикл
		Если ЭлементДерева.ПолучитьЭлементы().Количество() > 0 Тогда
			ЭтоДерево = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Если Не ЭтоДерево Тогда
		Элементы.Список.Отображение = ОтображениеТаблицы.Список;
	КонецЕсли;

	ВыполнитьСортировкуДерева();
КонецПроцедуры

&НаКлиенте
Функция ПолучитьОтредактированныйСписок()
	РедактируемыйСписок = Новый СписокЗначений;

	РедактируемыйСписок.Очистить();
	ЕстьНеотмеченные = Ложь;
	ЗаполнитьРедактируемыйСписок(РедактируемыйСписок, Список.ПолучитьЭлементы(), ЕстьНеотмеченные);

	Возврат РедактируемыйСписок;
КонецФункции

&НаСервере
Функция ПолучитьВетвьДерева(Представление, ОтбираемыеПараметры, Рекурсия = Ложь)
	СтрокиПути = СтрРазделить(Представление, ".");
	Если (ОтбираемыеПараметры = "Метаданные" Или ОтбираемыеПараметры = "Metadata") И СтрокиПути.Количество() > 2 Тогда
		ИмяОбъекта				= СтрокиПути[0];
		СтрокиПути.Удалить(0);
		ИмяОбъектаМетаданных	= СтрСоединить(СтрокиПути, ". ");
		СтрокиПути				= Новый Массив;
		СтрокиПути.Добавить(ИмяОбъекта);
		СтрокиПути.Добавить(ИмяОбъектаМетаданных);
	КонецЕсли;

	Если СтрокиПути.Количество() = 1 Тогда
		ЭлементыДерева	= Список.ПолучитьЭлементы();
		ИмяВетки		= СтрокиПути[0];
	ИначеЕсли СтрокиПути.Количество() = 0 Тогда
		ЭлементыДерева	= Список.ПолучитьЭлементы();
		ИмяВетки		= "";
	Иначе
		// Собираем путь к ветке родителя из фрагментов пути.
		ПредставлениеПутиРодителя = "";
		Для Сч = 0 По СтрокиПути.Количество() - 2 Цикл
			Если Не ПустаяСтрока(ПредставлениеПутиРодителя) Тогда
				ПредставлениеПутиРодителя = ПредставлениеПутиРодителя + ".";
			КонецЕсли;
			ПредставлениеПутиРодителя = ПредставлениеПутиРодителя + СтрокиПути[Сч];
		КонецЦикла;
		ЭлементыДерева	= ПолучитьВетвьДерева(ПредставлениеПутиРодителя, ОтбираемыеПараметры, Истина).ПолучитьЭлементы();
		ИмяВетки		= СтрокиПути[СтрокиПути.Количество() - 1];
	КонецЕсли;

	Если ДобавленныеВетки.НайтиПоЗначению(ИмяВетки) <> Неопределено Тогда
		Для Каждого ЭлементДерева Из ЭлементыДерева Цикл
			Если ЭлементДерева.Представление = ИмяВетки Тогда
				Если СтрокиПути.Количество() = 1 И Не Рекурсия Тогда
					Прервать;
				КонецЕсли;

				Возврат ЭлементДерева;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	// Не нашли, придется создавать.
	ДобавленныеВетки.Добавить(ИмяВетки);

	ЭлементДерева				= ЭлементыДерева.Добавить();
	ЭлементДерева.Представление	= ИмяВетки;
	ЭлементДерева.Пометка		= Ложь;

	Возврат ЭлементДерева;
КонецФункции

&НаКлиенте
Процедура ЗаполнитьРедактируемыйСписок(РедактируемыйСписок, ЭлементыДерева, ЕстьНеотмеченные)
	Для Каждого ЭлементДерева Из ЭлементыДерева Цикл
		Если ЭлементДерева.ПолучитьЭлементы().Количество() <> 0 Тогда
			ЗаполнитьРедактируемыйСписок(РедактируемыйСписок, ЭлементДерева.ПолучитьЭлементы(), ЕстьНеотмеченные);
		Иначе
			Если ЭлементДерева.Пометка Тогда
				НовыйЭлементСписка = РедактируемыйСписок.Добавить();
				НовыйЭлементСписка.Значение      = ЭлементДерева.Значение;
				НовыйЭлементСписка.Представление = ЭлементДерева.ПолноеПредставление;
			Иначе
				ЕстьНеотмеченные = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ОтметитьВстречающиесяЭлементы(ЭлементыДерева, РедактируемыйСписок)
	Для Каждого ЭлементДерева Из ЭлементыДерева Цикл
		Если ЭлементДерева.ПолучитьЭлементы().Количество() <> 0 Тогда
			ОтметитьВстречающиесяЭлементы(ЭлементДерева.ПолучитьЭлементы(), РедактируемыйСписок);
		Иначе
			Если РедактируемыйСписок.НайтиПоЗначению(ЭлементДерева.Значение) <> Неопределено Тогда
				ЭлементДерева.Пометка = Истина;
				ПроверитьСостояниеПометкиВетви(ЭлементДерева.ПолучитьРодителя());
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ОтметитьЭлементДерева(ЭлементДерева, Пометка, ПроверитьСостояниеПометкиВетви = Истина)
	ЭлементДерева.Пометка = Пометка;
	// Отметить все подчиненные элементы дерева.
	Для Каждого ПодчиненныйЭлементДерева Из ЭлементДерева.ПолучитьЭлементы() Цикл
		ОтметитьЭлементДерева(ПодчиненныйЭлементДерева, Пометка, Ложь);
	КонецЦикла;
	// Проверить, не должно ли измениться состояние родителя.
	Если ПроверитьСостояниеПометкиВетви Тогда
		ПроверитьСостояниеПометкиВетви(ЭлементДерева.ПолучитьРодителя());
	КонецЕсли;
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ПроверитьСостояниеПометкиВетви(Ветвь)
	Если Ветвь = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ПодчиненныеВетви	= Ветвь.ПолучитьЭлементы();

	ЕстьИстина	= Ложь;
	ЕстьЛожь	= Ложь;
	Для Каждого ПодчиненнаяВетвь Из ПодчиненныеВетви Цикл
		Если ПодчиненнаяВетвь.Пометка Тогда
			ЕстьИстина = Истина;
			Если ЕстьЛожь Тогда
				Прервать;
			КонецЕсли;
		Иначе
			ЕстьЛожь = Истина;
			Если ЕстьИстина Тогда
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Если ЕстьИстина Тогда
		Если ЕстьЛожь Тогда
			// Есть и помеченные и непомеченные, у себя при необходимости ставим не помечено и проверяем родителя.
			Если Ветвь.Пометка Тогда
				Ветвь.Пометка = Ложь;
				ПроверитьСостояниеПометкиВетви(Ветвь.ПолучитьРодителя());
			КонецЕсли;
		Иначе
			// Все подчиненные помечены
			Если Не Ветвь.Пометка Тогда
				Ветвь.Пометка = Истина;
				ПроверитьСостояниеПометкиВетви(Ветвь.ПолучитьРодителя());
			КонецЕсли;
		КонецЕсли;
	Иначе
		// Все подчиненные не помечены.
		Если Ветвь.Пометка Тогда
			Ветвь.Пометка = Ложь;
			ПроверитьСостояниеПометкиВетви(Ветвь.ПолучитьРодителя());
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура УстановкаПометок(Значение, ВеткаДерева = Неопределено)
	Если ВеткаДерева = Неопределено Тогда
		ВеткаДерева = Список;
	КонецЕсли;

	Для Каждого СтрокаСписка Из ВеткаДерева.ПолучитьЭлементы() Цикл
		СтрокаСписка.Пометка = Значение;
		УстановкаПометок(Значение, СтрокаСписка);
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ВыполнитьСортировкуДерева()
	СписокДерево = РеквизитФормыВЗначение("Список");
	СписокДерево.Строки.Сортировать("Представление Возр", Истина);
	ЗначениеВРеквизитФормы(СписокДерево, "Список");
КонецПроцедуры
