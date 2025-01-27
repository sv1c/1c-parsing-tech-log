#Область Автозагрузка

Процедура АвтозагрузкаРегламентное(Замер) Экспорт
	
	ФайлыДляЗагрузки = новый Массив;
	
	//Получить параметры задания
	РеквизитыЗадания = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Замер, "ПолныйПуть,ЗагрузкаВРеальномВремени, НачалоПериода, КонецПериода, ФильтрТипПроцесса, ТипЗамера");
	РеквизитыЗадания.Вставить("Замер", Замер); 
	РеквизитыЗадания.Вставить("ФильтрТипПроцесса", РеквизитыЗадания.ФильтрТипПроцесса.Получить());
	
	//Получить файлы для загрузки
	Если РеквизитыЗадания.ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.ТехнологическийЖурнал") Тогда
		ФайлыДляЗагрузки = ПолучитьСписокФайлов(РеквизитыЗадания);
	ИначеЕсли РеквизитыЗадания.ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.PerfomanceMonitor") Тогда
		ФайлыДляЗагрузки = ПолучитьСписокФайловPerfomanceMonitor(РеквизитыЗадания);
	Иначе
		//TODO: Добавить вызов обработки для определения списка файлов
	КонецЕсли;	
	 
	ЗагрузкаФайловТЖ(Замер, ФайлыДляЗагрузки);
	
КонецПроцедуры


// Описание
// 
// Параметры:
// 	РеквизитыЗадания - Структура, Структура - Описание
// Возвращаемое значение:
// 	СписокЗначений - Описание
Функция ПолучитьСписокФайлов(РеквизитыЗадания)
	Результат = Новый ТаблицаЗначений();
	Результат.Колонки.Добавить("ПолноеИмя", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("Процесс", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ПроцессИД", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ПериодФайла", Новый ОписаниеТипов("Дата"));
	
	ИспользуетсяОграничениеПериода = ЗначениеЗаполнено(РеквизитыЗадания.НачалоПериода) ИЛИ ЗначениеЗаполнено(РеквизитыЗадания.КонецПериода);
	ИмяТекущегоФайла = Формат(ТекущаяДата() + 300,"ДФ=ггММддЧЧ;"); //добавим 5 минут для надежности
	
	СписокФайлов = НайтиФайлы(РеквизитыЗадания.ПолныйПуть, "*.log", Истина);
	Для Каждого Файл из СписокФайлов Цикл
		//пропускать каталоги
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		//пропускать пустые файлы
		Если Файл.Размер()<=3 Тогда
			Продолжить;
		КонецЕсли;		
		// определим период файла, для других логов будет дата изменения
		ПериодФайла = ПолучитьПериодПоИмениФайла(Файл.ИмяБезРасширения);
		//пропускать если не в периоде загрузки
		Если ИспользуетсяОграничениеПериода Тогда
			Если ЗначениеЗаполнено(РеквизитыЗадания.НачалоПериода) И ПериодФайла < НачалоЧаса(РеквизитыЗадания.НачалоПериода) 
				ИЛИ ЗначениеЗаполнено(РеквизитыЗадания.КонецПериода) И ПериодФайла > НачалоЧаса(РеквизитыЗадания.КонецПериода) Тогда
				Продолжить;
			КонецЕсли;  
		КонецЕсли;
		//пропускать файл текущего периода если не загрузка в реальном времени
		Если НЕ РеквизитыЗадания.ЗагрузкаВРеальномВремени  			
			И Файл.ИмяБезРасширения = ИмяТекущегоФайла Тогда
			Продолжить;			
		КонецЕсли;	
		//фильтр по процессу, если установлен
		Процесс = ПолучитьПроцессПоИмениФайла(Файл.ПолноеИмя);
		Если РеквизитыЗадания.ФильтрТипПроцесса<>Неопределено
			И РеквизитыЗадания.ФильтрТипПроцесса.Количество()
			И РеквизитыЗадания.ФильтрТипПроцесса.НайтиПоЗначению(Процесс)=Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ФайлЗамера = Справочники.ФайлыЗамера.ПолучитьФайлПоПолномуИмени(РеквизитыЗадания.Замер, Файл.ПолноеИмя);
		СостояниеЧтения = РегистрыСведений.СостояниеЧтения.ПолучитьСостояние(ФайлЗамера);
		//пропускать прочитанные
		Если СостояниеЧтения.ЧтениеЗавершено Тогда
			Продолжить;
		КонецЕсли;		
		//пропускать если размер с прошного сеанса не изменился
		Если Файл.Размер() = СостояниеЧтения.Размер Тогда
			Продолжить;
		КонецЕсли;		
		
		строкарезультата 				= Результат.Добавить();
		строкарезультата.ПолноеИмя 		= Файл.ПолноеИмя;
		строкарезультата.ПериодФайла 	= ПериодФайла;
		строкарезультата.Процесс 		= Процесс;
	КонецЦикла;

	Результат.Сортировать("ПериодФайла");
	
	Возврат Результат;
КонецФункции

// Описание
// 
// Параметры:
// 	РеквизитыЗадания - Структура, Структура - Описание
// Возвращаемое значение:
// 	СписокЗначений - Описание
Функция ПолучитьСписокФайловPerfomanceMonitor(РеквизитыЗадания)
	Результат = Новый ТаблицаЗначений();
	Результат.Колонки.Добавить("ПолноеИмя", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("Процесс", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ПроцессИД", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ПериодФайла", Новый ОписаниеТипов("Дата"));
	
	ИспользуетсяОграничениеПериода = ЗначениеЗаполнено(РеквизитыЗадания.НачалоПериода) ИЛИ ЗначениеЗаполнено(РеквизитыЗадания.КонецПериода);
	ДатаТекущегоФайла = ТекущаяДата() + 300; //добавим 5 минут для надежности
	
	Маска = "*.csv";
	
	СписокФайлов = НайтиФайлы(РеквизитыЗадания.ПолныйПуть, Маска, Истина);
	Для Каждого Файл из СписокФайлов Цикл
		//пропускать каталоги
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		//пропускать пустые файлы
		Если Файл.Размер()<=3 Тогда
			Продолжить;
		КонецЕсли;		
		// определим период файла, для других логов будет дата изменения
		ПериодФайла = Файл.ПолучитьВремяИзменения();
		//пропускать если не в периоде загрузки
		Если ИспользуетсяОграничениеПериода Тогда
			Если ЗначениеЗаполнено(РеквизитыЗадания.НачалоПериода) И ПериодФайла < НачалоЧаса(РеквизитыЗадания.НачалоПериода) 
				ИЛИ ЗначениеЗаполнено(РеквизитыЗадания.КонецПериода) И ПериодФайла > НачалоЧаса(РеквизитыЗадания.КонецПериода) Тогда
				Продолжить;
			КонецЕсли;  
		КонецЕсли;
		
		ФайлЗамера = Справочники.ФайлыЗамера.ПолучитьФайлПоПолномуИмени(РеквизитыЗадания.Замер, Файл.ПолноеИмя);
		СостояниеЧтения = РегистрыСведений.СостояниеЧтения.ПолучитьСостояние(ФайлЗамера);
		//пропускать прочитанные
		Если СостояниеЧтения.ЧтениеЗавершено Тогда
			Продолжить;
		КонецЕсли;	
		//если размер не меняется, изменение более 3 часов назад, то ставим завершено чтение
		Если Файл.Размер() = СостояниеЧтения.Размер
			И (ТекущаяДата()-ПериодФайла)>3600*3 Тогда
			РегистрыСведений.СостояниеЧтения.УстановитьСостояние(ФайлЗамера,
			ПериодФайла,
			СостояниеЧтения.Прочитанострок,
			ТекущаяДата(),
			СостояниеЧтения.Размер);	
		КонецЕсли;
		//пропускать если размер с прошного сеанса не изменился
		Если Файл.Размер() = СостояниеЧтения.Размер Тогда
			Продолжить;
		КонецЕсли;		
		
		строкарезультата 				= Результат.Добавить();
		строкарезультата.ПолноеИмя 		= Файл.ПолноеИмя;
		строкарезультата.ПериодФайла 	= ПериодФайла;
	КонецЦикла;

	Результат.Сортировать("ПериодФайла");
	
	Возврат Результат;
КонецФункции

Процедура ЗагрузкаФайловТЖ(Замер, ФайлыДляЗагрузки)
	
	ТипЗамера = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Замер,"ТипЗамера" );
	
	Если ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.ТехнологическийЖурнал") Тогда
		Для Каждого строкарезультата Из ФайлыДляЗагрузки Цикл
			ОбновлениеДанных.РазобратьФайлВСправочник(Замер, строкарезультата.ПолноеИмя);
		КонецЦикла; 
	ИначеЕсли ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.PerfomanceMonitor") Тогда
		Для Каждого строкарезультата Из ФайлыДляЗагрузки Цикл			
			СтруктураПараметров = Новый Структура("ПолноеИмя,ПериодФайла",
			строкарезультата.ПолноеИмя,строкарезультата.ПериодФайла);
			ОбновлениеДанных.РазобратьФайлВСправочникPerfomanceMonitor(Замер, СтруктураПараметров);
		КонецЦикла; 
	ИначеЕсли ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.Произвольный") Тогда
		СтруктураПараметров = новый Структура(); 
		ОбновлениеДанных.РазобратьФайлВСправочникПроизвольный(Замер,СтруктураПараметров);			
	Иначе
		ЗаписьЖурналаРегистрации("ЧтениеВСправочник",УровеньЖурналаРегистрации.Ошибка,Неопределено,Неопределено,"Не поддерживаемый тип ("+ТипЗамера+") для замера:"+Замер);
	КонецЕсли;
	
КонецПроцедуры

//дата по имени файла: ГГММДДЧЧ
Функция ПолучитьПериодПоИмениФайла(ЗНАЧ ИмяБезРасширения) Экспорт
	Результат = Дата(1,1,1);
	// Для perfmon попробуем взять с конца
	Если СтрДлина(ИмяБезРасширения)>8 Тогда
		ИмяБезРасширения = Прав(ИмяБезРасширения,8);
	КонецЕсли;
	Если СтрДлина(ИмяБезРасширения)=8 Тогда
		Попытка
			Результат = Дата(2000+Число(Сред(ИмяБезРасширения,1,2)), 
								Число(Сред(ИмяБезРасширения,3,2)), 
								Число(Сред(ИмяБезРасширения,5,2)), 
								Число(Сред(ИмяБезРасширения,7,2)), 
								0, 
								0);
		Исключение
		КонецПопытки;
	КонецЕсли;	
	Возврат Результат;
КонецФункции

Функция ПолучитьПроцессПоИмениФайла(ЗНАЧ ПолноеИмяФайла) Экспорт
	Результат = Справочники.Процессы.ПустаяСсылка();
	Попытка
		ПолноеИмяМассив = СтрРазделить(ПолноеИмяФайла, "\");
		ПоследняяЧастьКаталога = ПолноеИмяМассив[ПолноеИмяМассив.ВГраница()-1];
		Процесс = Лев(ПоследняяЧастьКаталога, СтрНайти(ПоследняяЧастьКаталога, "_")-1);
		Результат = СправочникиСерверПовтИсп.ПолучитьПроцесс(Процесс);
	Исключение
	КонецПопытки;
	Возврат Результат;
КонецФункции

#КонецОбласти

#Область Удаление

Процедура УдалениеУстаревшихСобытий() Экспорт
	СписокНастроекДляОчистки = ПолучитьНастройкиУдаления();
	Если СписокНастроекДляОчистки.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого настройкаудаления из СписокНастроекДляОчистки Цикл
		ВыполнитьОчисткуПоНастройке(настройкаудаления);
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьНастройкиУдаления()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Замеры.Ссылка,
	|	Замеры.ГлубинаХранения
	|ИЗ
	|	Справочник.Замеры КАК Замеры
	|ГДЕ
	|	Замеры.ГлубинаХранения <> 0";
	Результат = Запрос.Выполнить().Выгрузить();
	Возврат Результат;
КонецФункции

Процедура ВыполнитьОчисткуПоНастройке(настройкаудаления, НеЗаписыватьЗамер = Ложь) Экспорт
	//1.очистка событий по отбору
	//2.очистика файлов (перенесена в другое РЗ)
	РазмерПакетаУдаления = Константы.РазмерПакетаУдаляемыхДанных.Получить();
	ГраничнаяДата = НачалоДня(ТекущаяДата() - 24*3600*настройкаудаления.ГлубинаХранения);
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1000
	               |	СобытияЗамера.Ссылка КАК Ссылка
	               |ИЗ
	               |	Справочник.СобытияЗамера КАК СобытияЗамера
	               |ГДЕ
	               |	СобытияЗамера.Владелец = &Замер
	               |	И СобытияЗамера.ДатаСобытия < &Период
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	СобытияЗамера.ДатаСобытия";
	Если РазмерПакетаУдаления=0 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"ПЕРВЫЕ 1000","");
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"ПЕРВЫЕ 1000"," ПЕРВЫЕ "+XMLСтрока(РазмерПакетаУдаления));
	КонецЕсли;
	Запрос.УстановитьПараметр("Замер", настройкаудаления.Ссылка);
	Запрос.УстановитьПараметр("Период", ГраничнаяДата);
	ВыборкаСобытия = Запрос.Выполнить().Выбрать();
	Пока ВыборкаСобытия.Следующий() Цикл
		СобытиеОбъект = ВыборкаСобытия.Ссылка.ПолучитьОбъект();
		СобытиеОбъект.Удалить();
	КонецЦикла;
	Если НеЗаписыватьЗамер Тогда
		Возврат;
	КонецЕсли;	
	//запишем дату не расчетную а фактическую (что осталось после очистки)
	НачалоПериодаЗамера = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(настройкаудаления.Ссылка, "НачалоПериода");
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	СобытияЗамера.ДатаСобытия КАК Дата
	               |ИЗ
	               |	Справочник.СобытияЗамера КАК СобытияЗамера
	               |ГДЕ
	               |	СобытияЗамера.Владелец = &Замер
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	ДатаСобытия";
	Запрос.УстановитьПараметр("Замер", настройкаудаления.Ссылка);
	ВыборкаМинДата = Запрос.Выполнить().Выбрать();
	Если ВыборкаМинДата.Следующий() Тогда
		НоваяГраничнаяДата = ВыборкаМинДата.Дата;
	Иначе
		НоваяГраничнаяДата = ГраничнаяДата;
	КонецЕсли;
	
	Если НачалоПериодаЗамера < НоваяГраничнаяДата
		ИЛИ НЕ ЗначениеЗаполнено(НачалоПериодаЗамера) Тогда
			ЗамерОбъект = настройкаудаления.Ссылка.ПолучитьОбъект();
			ЗамерОбъект.НачалоПериода = НоваяГраничнаяДата;
			Попытка
				ЗамерОбъект.Записать(); 
			Исключение
				ЗаписьЖурналаРегистрации("РегламентноеЗадание.УдалениеУстаревшихСобытий",
					УровеньЖурналаРегистрации.Ошибка,
					настройкаудаления.Ссылка.Метаданные(),
					настройкаудаления.Ссылка,
					"Ошибка при установке новой граничной даты" + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			КонецПопытки;
	КонецЕсли;
КонецПроцедуры

Процедура УдалениеНеиспользуемыхФайлов() Экспорт
	СписокНастроекДляОчистки = ПолучитьНастройкиУдаления();
	Если СписокНастроекДляОчистки.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого настройкаудаления из СписокНастроекДляОчистки Цикл
		УдалениеНеиспользуемыхФайловПоНастройке(настройкаудаления);
	КонецЦикла;
КонецПроцедуры


Процедура УдалениеНеиспользуемыхФайловПоНастройке(настройкаудаления, НеЗаписыватьЗамер = Ложь) Экспорт
	ГраничнаяДата = НачалоДня(ТекущаяДата() - 24*3600*настройкаудаления.ГлубинаХранения);
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ ПЕРВЫЕ 1000
	               |	ФайлыЗамера.Ссылка КАК Ссылка
	               |ИЗ
	               |	Справочник.ФайлыЗамера КАК ФайлыЗамера
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СобытияЗамера КАК СобытияЗамера
	               |		ПО СобытияЗамера.Файл = ФайлыЗамера.Ссылка
	               |ГДЕ
	               |	ФайлыЗамера.Владелец = &Замер
	               |	И ФайлыЗамера.ДатаФайла < &Период
	               |	И НЕ ФайлыЗамера.ДатаФайла = ДАТАВРЕМЯ(1, 1, 1)
	               |	И СобытияЗамера.Файл ЕСТЬ NULL";
	Запрос.УстановитьПараметр("Замер", настройкаудаления.Ссылка);
	Запрос.УстановитьПараметр("Период", ГраничнаяДата);
	ВыборкаФайлы = Запрос.Выполнить().Выбрать();
	Пока ВыборкаФайлы.Следующий() Цикл
		ФайлОбъект = ВыборкаФайлы.Ссылка.ПолучитьОбъект();
		Попытка
			ФайлОбъект.Удалить();
		Исключение
			ЗаписьЖурналаРегистрации("РегламентноеЗадание.УдалениеУстаревшихФайлов",
				УровеньЖурналаРегистрации.Ошибка,
				ВыборкаФайлы.Ссылка.Метаданные(),
				ВыборкаФайлы.Ссылка,
				"Ошибка при удалении файла" + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецПопытки;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти
