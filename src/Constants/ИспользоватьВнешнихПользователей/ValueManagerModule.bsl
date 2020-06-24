///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Перем ЗначениеИзменено;

Процедура ПередЗаписью(Отказ)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	ЗначениеИзменено = Значение <> Константы.ИспользоватьВнешнихПользователей.Получить();

	Если ЗначениеИзменено
	   И Значение
	   И Не ПользователиСерверПовтИсп.сП_ПустыеСсылкиТиповОбъектовАвторизации().Количество() > 0 Тогда

		ВызватьИсключение "Использование внешних пользователей не предусмотрено в программе.";
	КонецЕсли;
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	Если ЗначениеИзменено Тогда
		ПользователиСервер.сП_ОбновитьРолиВнешнихПользователей();

		//Зарезервировано для новых подсистем

		Если Значение Тогда
			ОчиститьРеквизитПоказыватьВСпискеВыбораУВсехПользователейИБ();
		Иначе
			ОчиститьРеквизитВходВПрограммуРазрешенУВсехВнешнихПользователей();
		КонецЕсли;

		УстановитьПризнакИспользованияНабораСвойств();
	КонецЕсли;
КонецПроцедуры

Процедура ОчиститьРеквизитПоказыватьВСпискеВыбораУВсехПользователейИБ()
	ПользователиИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого ПользовательИБ Из ПользователиИБ Цикл
		Если ПользовательИБ.ПоказыватьВСпискеВыбора Тогда
			ПользовательИБ.ПоказыватьВСпискеВыбора = Ложь;
			ПользовательИБ.Записать();
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура ОчиститьРеквизитВходВПрограммуРазрешенУВсехВнешнихПользователей()
	Запрос			= Новый Запрос;
	Запрос.Текст	=
	"ВЫБРАТЬ
	|	ВнешниеПользователи.ИдентификаторПользователяИБ КАК Идентификатор
	|ИЗ
	|	Справочник.ВнешниеПользователи КАК ВнешниеПользователи";
	Идентификаторы = Запрос.Выполнить().Выгрузить();
	Идентификаторы.Индексы.Добавить("Идентификатор");

	ПользователиИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого ПользовательИБ Из ПользователиИБ Цикл
		Если Идентификаторы.Найти(ПользовательИБ.УникальныйИдентификатор, "Идентификатор") <> Неопределено
		   И ПользователиСервер.П_ВходВПрограммуРазрешен(ПользовательИБ) Тогда

			ПользовательИБ.АутентификацияСтандартная = Ложь;
			ПользовательИБ.АутентификацияОС          = Ложь;
			ПользовательИБ.АутентификацияOpenID      = Ложь;
			ПользовательИБ.Записать();
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура УстановитьПризнакИспользованияНабораСвойств()
	// Зарезервировано для новых подсистем
КонецПроцедуры

#Иначе
ВызватьИсключение "Недопустимый вызов объекта на клиенте.";
#КонецЕсли
