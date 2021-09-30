#Область ДополнительныеОбработки

Функция СведенияОВнешнейОбработке() Экспорт
	
	МассивНазначений = Новый Массив;
	
	ПараметрыРегистрации = Новый Структура;
	ПараметрыРегистрации.Вставить("Вид", "ДополнительнаяОбработка");
	ПараметрыРегистрации.Вставить("Назначение", МассивНазначений);
	ПараметрыРегистрации.Вставить("Наименование", "Панель наборов графиков (Grafana Skin)");
	ПараметрыРегистрации.Вставить("Версия", "2021.06.25");
	ПараметрыРегистрации.Вставить("БезопасныйРежим", Ложь);
	ПараметрыРегистрации.Вставить("Информация", ИнформацияПоИсторииИзменений());
	ПараметрыРегистрации.Вставить("ВерсияБСП", "1.2.1.4");
	ТаблицаКоманд = ПолучитьТаблицуКоманд();
	ДобавитьКоманду(ТаблицаКоманд,
	                "Панель наборов графиков (Grafana Skin)",
					"GrafanaSkin",
					"ОткрытиеФормы",
					Истина,
					"",
					"Форма"
					);

	ПараметрыРегистрации.Вставить("Команды", ТаблицаКоманд);
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Функция ПолучитьТаблицуКоманд()
	
	Команды = Новый ТаблицаЗначений;
	Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	Команды.Колонки.Добавить("ПросмотрВсе", Новый ОписаниеТипов("Булево"));
	Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("ИмяФормы", Новый ОписаниеТипов("Строка"));
	
	Возврат Команды;
	
КонецФункции

Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование, ПоказыватьОповещение = Ложь, Модификатор = "", ИмяФормы="",ПросмотрВсе=Истина)
	
	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;
	НоваяКоманда.ИмяФормы = ИмяФормы;
	НоваяКоманда.ПросмотрВсе = ПросмотрВсе;
	
КонецПроцедуры

Функция ИнформацияПоИсторииИзменений()
	Возврат "
	| <div style='text-indent: 25px;'>Данная обработка позволяет отображать наборы графиков по данным замеров</div>
	| <div style='text-indent: 25px;'>Возможности:<ul>
	| <li>Поддерживается неограниченное количество схем с настройками экранов. Схемами можно делить различные системы мониторинга.</li>
	| <li>У пользователя есть возможность создать неограниченное количество экранов с 1 или до 6 диаграмм.</li>
	| <li>На каждой диаграмме возможно размещение требуемого количества графиков. Рекомендуем выбирать параметры в одинаковом масштабе и количеством не более 3-4 (иначе трудно анализировать).</li>
	| </ul>
	| <hr />
	| <div style='text-indent: 25px;'>Автор идеи: Крючков Владимир.</div>
	| <div style='text-indent: 25px;'>Реализовали: Крючков Владимир.</div>
	| <hr />
	| Подробную информацию смотрите по адресу интернет: <a target='_blank' href='https://github.com/Polyplastic/1c-parsing-tech-log'>https://github.com/Polyplastic/1c-parsing-tech-log</a>";
	
КонецФункции

Процедура ВыполнитьКоманду(Знач ИдентификаторКоманды, ПараметрыКоманды=Неопределено) Экспорт
	
	Если ИдентификаторКоманды="ПолучитьДанныеКластераФоново" Тогда
		
		// только при наличии параметров
		Если ПараметрыКоманды=Неопределено Тогда
			Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти