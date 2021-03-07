///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ОбновитьДанныеРегистра(ЕстьИзменения = Неопределено) Экспорт
	УстановитьПривилегированныйРежим(Истина);

	Блокировка = Новый БлокировкаДанных;
	Блокировка.Добавить("РегистрСведений.СоставыГруппПользователей");

	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();

		// Обновление связей пользователей.
		УчастникиИзменений = Новый Соответствие;
		ИзмененныеГруппы   = Новый Соответствие;

		Выборка = Справочники.ГруппыПользователей.Выбрать();
		Пока Выборка.Следующий() Цикл
			ПользователиСервер.сП_ОбновитьСоставыГруппПользователей(Выборка.Ссылка, , УчастникиИзменений, ИзмененныеГруппы);
		КонецЦикла;

		// Обновление связей внешних пользователей.
		Выборка = Справочники.ГруппыВнешнихПользователей.Выбрать();
		Пока Выборка.Следующий() Цикл
			ПользователиСервер.сП_ОбновитьСоставыГруппВнешнихПользователей(Выборка.Ссылка, , УчастникиИзменений, ИзмененныеГруппы);
		КонецЦикла;

		Если УчастникиИзменений.Количество() > 0 ИЛИ ИзмененныеГруппы.Количество() > 0 Тогда
			ЕстьИзменения = Истина;

			ПользователиСервер.сП_ПослеОбновленияСоставовГруппПользователей(УчастникиИзменений, ИзмененныеГруппы);
		КонецЕсли;

		ПользователиСервер.сП_ОбновитьРолиВнешнихПользователей();

		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
КонецПроцедуры

#КонецЕсли
