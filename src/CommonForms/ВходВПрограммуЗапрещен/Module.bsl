///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПодключитьОбработчикОжидания("ОбработчикОжиданияЗавершитьРаботу", 5 * 60, Истина);
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	ПрекратитьРаботуСистемы();
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьРаботу(Команда)
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОжиданияЗавершитьРаботу()
	Закрыть();
КонецПроцедуры
