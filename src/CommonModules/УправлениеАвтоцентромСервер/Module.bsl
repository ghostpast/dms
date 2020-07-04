
Процедура ПриДобавленииПодсистем(МодулиПодсистем) Экспорт
	МодулиПодсистем.Добавить("УправлениеАвтоцентромСервер");
КонецПроцедуры

Процедура ПриДобавленииПодсистемы(Описание) Экспорт
	Описание.Имя										= "УправлениеАвтоцентром";
	Описание.Версия										= "1.0.0.1";
	Описание.ИдентификаторИнтернетПоддержки				= "SSL";
	Описание.РежимВыполненияОтложенныхОбработчиков		= "Параллельно";
	Описание.ПараллельноеОтложенноеОбновлениеСВерсии	= "1.0.0.0";

	Описание.ТребуемыеПодсистемы.Добавить("СтандартныеПодсистемы");
КонецПроцедуры

Процедура ПриОпределенииРежимаОбновленияДанных(РежимОбновленияДанных, СтандартнаяОбработка) Экспорт

КонецПроцедуры

Процедура ПередОбновлениемИнформационнойБазы() Экспорт

КонецПроцедуры

Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	Обработчик						= Обработчики.Добавить();
	Обработчик.НачальноеЗаполнение	= Истина;
	Обработчик.Процедура			= "УправлениеАвтоцентромСервер.УА_ПервыйЗапуск";
КонецПроцедуры

Процедура УА_ПервыйЗапуск() Экспорт
	Константы.ЗаголовокСистемы.Установить(Метаданные.Представление());
КонецПроцедуры
