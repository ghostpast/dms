///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ВариантыОтчетов

Процедура ВО_ПриПодключенииОтчета(ПараметрыОткрытия) Экспорт
	ВариантыОтчетовСервер.ВО_ПриПодключенииОтчета(ПараметрыОткрытия);
КонецПроцедуры

Функция ВО_СвойстваВариантОтчетаИзФайла(ОписаниеФайла, ВариантОтчетаОснование) Экспорт
	Возврат ВариантыОтчетовСервер.ВО_СвойстваВариантОтчетаИзФайла(ОписаниеФайла, ВариантОтчетаОснование);
КонецФункции

#КонецОбласти
