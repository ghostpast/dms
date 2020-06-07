///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ОбновитьДанныеСправочника(ЕстьИзменения = Ложь, ЕстьУдаленные = Ложь, ТолькоПроверка = Ложь) Экспорт
	Справочники.ИдентификаторыОбъектовМетаданных.ВыполнитьОбновлениеДанных(ЕстьИзменения, ЕстьУдаленные, ТолькоПроверка, , , Истина);
КонецПроцедуры

Функция ОбъектРасширенияОтключен(Идентификатор) Экспорт
	БазоваяПодсистемаСерверПовтИсп.СП_ИдентификаторыОбъектовМетаданныхПроверкаИспользования(Истина, Истина);

	Запрос			= Новый Запрос;
	Запрос.Текст	=
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ИСТИНА КАК ЗначениеИстина
	|ИЗ
	|	Справочник.ИдентификаторыОбъектовРасширений КАК Идентификаторы
	|ГДЕ
	|	Идентификаторы.Ссылка = &Ссылка
	|	И НЕ Идентификаторы.ПометкаУдаления
	|	И НЕ ИСТИНА В
	|				(ВЫБРАТЬ ПЕРВЫЕ 1
	|					ИСТИНА
	|				ИЗ
	|					РегистрСведений.ИдентификаторыОбъектовВерсийРасширений КАК ВерсииИдентификаторов
	|				ГДЕ
	|					ВерсииИдентификаторов.Идентификатор = Идентификаторы.Ссылка
	|					И ВерсииИдентификаторов.ВерсияРасширений = &ВерсияРасширений)";
	Запрос.УстановитьПараметр("Ссылка", Идентификатор);
	Запрос.УстановитьПараметр("ВерсияРасширений", ПараметрыСеанса.ВерсияРасширений);

	Возврат Не Запрос.Выполнить().Пустой();
КонецФункции

Функция ИдентификаторыОбъектовТекущейВерсииРасширенийЗаполнены() Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ИСТИНА КАК ЗначениеИстина
	|ИЗ
	|	РегистрСведений.ИдентификаторыОбъектовВерсийРасширений КАК ВерсииИдентификаторов
	|ГДЕ
	|	ВерсииИдентификаторов.ВерсияРасширений = &ВерсияРасширений";
	Запрос.УстановитьПараметр("ВерсияРасширений", ПараметрыСеанса.ВерсияРасширений);

	Возврат Не Запрос.Выполнить().Пустой();
КонецФункции

#КонецЕсли
