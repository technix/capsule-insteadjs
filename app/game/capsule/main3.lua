-- $Name: Капсула$
-- $Version: 1.1$
-- $Author: techniX$
-- $Info: Музыка:\n Antethic - Tsunami Museum (CC BY-NC 3.0)\n\nЧтобы осмотреть предмет в инвентаре, тапните по нему.\nЧтобы применить предмет, перетащите его из инвентаря на другой предмет в инвентаре или в комнате.$
--[[

Если Вы еще не играли в эту игру,
не читайте, пожалуйста, дальше,
чтобы не испортить удовольствие от игры :)

История версий:
1.0
- первая версия, для "Паровозик-2017"

1.1
- исправлен финал - убрана ненужная ссылка
- исправлен люк - открыть можно только один раз
- исправлен вентиль
  
]]--

require "noinv"
require "snd"
require "fmt"
require "theme"
fmt.para = true

game.use = "Вряд ли это сработает."

global {
    is_warm = false;
    is_music = false;
}

function start()
    -- Play music
    if is_music then
        snd.vol(65)
        snd.music "music/antethic_-_tsunami_museum.ogg"
    end
end

room {
    nam = "main";
    disp = "";
    decor = function(s)
        p(fmt.c(fmt.img("gfx/intro.png") .. "^^{#начало|Начать игру}"))
    end;
    enter = function() 
        fmt.para = false
    end;
    exit = function() 
        is_music = true;
        start()
        fmt.para = true
    end;
}:with{
    obj {
        nam = "#начало";
        act = function()
            walk "wake"
        end
    }
}

room {
    nam = "wake";
    noinv = true;
    way = { path { "path_chamber", "Выйти из капсулы", "chamber" }:disable() };
    disp = "";
    enter = function() 
        p(fmt.em("Темнота.^Холод.^Запах металла.^Пробуждение от анабиоза оказалось совершенно не таким, как я представлял.^Но почему до сих пор не сработала автоматика? Капсула уже должна была открыться!"))
    end;
    decor = "В капсуле {#dark|темно} и {#tight|тесно}.";
}:with{
    obj {
        nam = "#dark";
        act = function()
            p "Я совершенно ничего не вижу. Надеюсь, с моими глазами всё в порядке."
        end;
    },
    obj {
        nam = "#tight";
        act = function()
            p "Я попытался вытянуть руку, и мои пальцы тут же натолкнулись на холодный металл. Ощупывая стенки капсулы, я обнаружил какой-то {#рычаг|рычаг}."
        end;
    },
    obj {
        nam = "#рычаг";
        act = function()
            p "Я потянул рычаг, и металлический колпак капсулы со скрежетом распахнулся. Свет ударил мне в глаза. Подождав, пока глаза привыкнут к свету, я неуклюже выбрался из капсулы."
            walk "chamber"
        end
    }
}


room {
    nam = "chamber";
    disp = "Камера";
    way = {
        path { "path_storage", "Выйти из камеры", "cutscene1" }:disable(),
        path { "path_storage_real", "В хранилище", "storage"}:disable()
    };
    decor = function(s)
        p([[Круглая камера слабо {#свет|освещена}. В центре возвышается сложная {#конструкция|конструкция} из механизмов, труб и проводов, вокруг которой расположены {#капсулы|капсулы}.
        Герметичная {#выход1|дверь} в стене ]] .. ((s.door_opened) and "открыта" or "плотно закрыта") .. ".")
    end;
    --
    door_enabled = false;
    door_opened = false;
}:with{
    obj {
        nam = "#свет";
        act = function()
            p "Гладкие металлические стены и пол тускло блестят в полумраке. Видимо, мощности хватает только на резервное освещение."
        end
    },
    obj {
        nam = "#конструкция";
        act = function()
            p "Только благодаря этой машине стало возможным наше путешествие. Индикаторы на {#панель|панели управления} светятся мягким янтарным светом.";
        end;
        used = function(s,w)
            if w^"РазводнойКлюч" then
                p "Я ударил по корпусу машины. Раздался гулкий звук."
                return
            end
            return false
        end;
        has_wire = true;
    }:with{
        obj {
            nam = "#панель";
            act = function()
                walkin "control"
            end
        }
    },
    obj {
        nam = "#капсулы";
        act = function(s)
            p "Всего капсул пять. Моя капсула открыта.";
            if s.has_leather then
                p "Внутри виднеется кожаная {#обшивка|внутренняя обшивка}."
            end
        end;
        has_leather = true;
    },
    obj {
        nam = "#обшивка";
        act = function()
            p "Обшивка капсулы до сих пор теплая."
        end;
        used = function(s,w)
            if w^"Стекло" then
                if _"Стекло".is_sharp then
                    p "Стекло слишком острое, не хотелось бы порезать руки."
                    return
                end
                if _"#капсулы".has_leather then
                    p "На то, чтобы вырезать обшивку из капсулы, ушло немало времени."
                    take "Обшивка"
                    _"#капсулы".has_leather = false
                    return
                end
            end
            return false
        end;
    },
    obj {
        nam = "#выход1";
        act = function()
            if _"chamber".door_opened then
                p "Дверь открыта."
            else
                if _"chamber".door_enabled then
                    p "Я открыл дверь."
                    _"chamber".door_opened = true
                    enable "path_storage"
                else
                    p "Дверь закрыта. Я уверен, должен быть способ открыть её изнутри."
                end
            end
        end
    }
}

room {
    nam = "control";
    noinv = true;
    disp = "Панель управления";
    pic = function(s)
      return "gfx/scale-" .. s.voltage .. ".png"
    end;
    way = { path {"Закрыть", "chamber"} };
    enter = function(s)
        if s.unseen then
            p "Одного взгляда на индикаторы было достаточно, чтобы понять -- остальные капсулы вышли из строя. Выходит, из нас пятерых только мне повезло достичь точки назначения живым."
            s.unseen = false
        end
    end;
    decor = function(s)
        p("Капсулы:^| 1 {#тумблер1|" .. ((s.ctrl[1].status) and "ВКЛ" or "выкл") .. "} ")
        p("^| 2 {#тумблер2|" .. ((s.ctrl[2].status) and "ВКЛ" or "выкл") .. "} ")
        p("^| 3 {#тумблер3|" .. ((s.ctrl[3].status) and "ВКЛ" or "выкл") .. "} ")
        p("^| 4 {#тумблер4|" .. ((s.ctrl[4].status) and "ВКЛ" or "выкл") .. "} ")
        p("^| 5 {#тумблер5|" .. ((s.ctrl[5].status) and "ВКЛ" or "выкл") .. "} ^")
        p("^Дверь: {#тумблердверь|Открыть}^")
    end;
    --
    unseen = true;
    ctrl = {
        {status = false; voltage = 5},
        {status = false; voltage = 1},
        {status = false; voltage = 2},
        {status = true; voltage = 6},
        {status = false; voltage = 8},
        {status = false} -- дверь
    };
    switch = function(s, id)
        s.ctrl[id].status = not s.ctrl[id].status
        if s.ctrl[id].status then
            s.voltage = s.voltage - s.ctrl[id].voltage
        else
            s.voltage = s.voltage + s.ctrl[id].voltage
        end
        p("Я щелкнул тумблером.")
    end;
    voltage = 16;
}:with{
    obj {nam = "#тумблер1"; act = function(s) _"control":switch(1) end },
    obj {nam = "#тумблер2"; act = function(s) _"control":switch(2) end },
    obj {nam = "#тумблер3"; act = function(s) _"control":switch(3) end },
    obj {nam = "#тумблер4"; act = function(s) _"control":switch(4) end },
    obj {nam = "#тумблер5"; act = function(s) _"control":switch(5) end },
    obj {
        nam = "#тумблердверь";
        act = function(s)
            _"chamber".door_enabled = false;
            if (_"control".voltage > 9) then
                p("На щитке загорелась красная лампочка, означающая перегрузку цепи.")
            elseif (_"control".voltage == 9) then
                p("На щитке загорелась зеленая лампа. Где-то загудели механизмы, управляющие дверными замками.")
                _"chamber".door_enabled = true;
            else
                p("Никакого эффекта. Похоже, напряжения в цепи недостаточно для управления дверным реле.")
            end
        end;
    }
}


--[[
#############################################################################################################
]]--

room {
    nam = "cutscene1";
    noinv = true;
    disp = false;
    pic = "gfx/out.png";
    decor = function(s)
        p(fmt.em([[
Профессор с самого начала предупреждал нас, что это путешествие в один конец.^
Но цель того стоила. Увидеть своими глазами то, о чем мы сейчас только мечтаем -- кто бы отказался от такой перспективы? И я вызвался добровольцем.^
Вот только почему нас никто не встречает?^
        ]]))
        pn(fmt.c("{#next|...}"))
    end;
    enter = function(s)
        enable "path_storage_real"
        disable "path_storage"
    end;
}:with{
    obj { nam = "#next"; act = function() walk "storage" end }
}

--[[
#############################################################################################################
]]--

obj {
    nam = "Стекло";
    disp = "Осколок";
    inv = function(s)
        pr "Острый осколок стекла"
        if s.is_sharp then
            p "."
        else
            p ", наполовину обмотанный изолентой."
        end
    end;
    tak = "Я осторожно подобрал осколок с пола.";
    --
    is_sharp = true;
    used = function (s,w)
        if w^"Изолента" then
            if s.is_sharp then
                p "Аккуратно, чтобы не порезаться, я обмотал осколок изолентой. Теперь им можно пользоваться как ножом, если понадобится."
                s.is_sharp = false
            else
                p "Осколок стекла уже обмотан изолентой."
            end
            return
        end
        return false
    end;
}

obj {
    nam = "Бумаги";
    disp = "Бумаги";
    inv = "Несколько страниц отпечатанного на машинке текста. Для тех, кто должен был нас встретить, они имеют особое значение.";
    use = function (s,w)
        p "Нет, эти бумаги слишком ценны."
    end;
    used = function (s,w)
        p "Нет, эти бумаги слишком ценны."
    end;
}

obj {
    nam = "Обшивка";
    disp = "Обшивка";
    inv = "Кожаная обшивка капсулы с утепляющими вставками.";
    tak = "Я забрал обшивку.";
    used = function (s,w)
        if w^"Стекло" then
            if _"storage".is_open == true then
                p "Разрезав обшивку на куски, я затолкал их под одежду. Теперь будет намного теплее."
                purge "Обшивка"
                is_warm = true
                enable "path_hall"
            else
                p "Думаю, обшивка мне еще понадобится целой."
            end
            return
        end
        return false
    end;
}

obj {
    nam = "РазводнойКлюч";
    disp = "Разводной ключ";
    inv = "Разводной ключ. Выглядит как новенький, никаких следов ржавчины.";
    tak = "Я взял разводной ключ.";
}


room {
    nam = "storage";
    disp = "Хранилище";
    way = {
        path { "В камеру", "chamber" },
        path {"path_engineroom", "В люк", "engineroom" }:disable(),
        path {"path_stairs", "Наружу", "stairs" }:disable(),
        path {"path_stairs_real", "К лестницам", "stairs" }:disable()
    };
    decor = function(s)
        if _"#glasscube".is_broken then
            pr "Пол в центре помещения усеян {#стекло|осколками стекла}"
            if have "Бумаги" then
                p "."
            else
                p ", среди которых лежит несколько {#бумага|листов бумаги}."
            end
        else
            p "Посреди комнаты тускло поблескивает {#glasscube|стеклянный куб}."
        end
        p "Вдоль стен выстроились ряды однообразных металлических {#ящики|ящиков}."
        p "В полу возле входа в камеру виден небольшой {#люк|люк}.^"
        if _"storage".is_open then
            p "Створки {#хрдверь|двери хранилища} частично раскрыты, из темной {#щель|щели} между ними веет холодом."
        else
            p "Огромная двустворчатая {#хрдверь|дверь хранилища} закрыта."
        end
    end;
    is_open = false;
    hatch_is_visible = false;
}:with{
    obj {
        nam = "#ящики";
        act = function(s)
            p "Надписи на ящиках уже не разобрать. А обыскивать их наугад у меня нет ни времени, ни желания."
            if s.here_wrench then
                p "^Между ящиками лежит {#развключ|разводной ключ}. Интересно, кто мог обронить его тут?"
            end
        end;
        --
        here_wrench = true;
    }:with{
        obj {
            nam = "#развключ";
            act = function(s)
                p "Я подобрал с пола разводной ключ."
                take "РазводнойКлюч"
                _"#ящики".here_wrench = false
            end;
        }
    },
    obj {
        nam = "#хрдверь";
        act = function()
            if _"storage".is_open then
                p "Похоже, за эти годы механизмы пришли в негодность, и дверь невозможно открыть полностью."
            else
                p "Хранилище спроектировано так, что дверь можно открыть только снаружи. Мне нужно найти способ открыть её изнутри."
            end
        end;
    },
    obj {
        nam = "#щель";
        act = function()
            p "Ширины щели вполне достаточно, чтобы я смог протиснуться."
            if disabled("path_stairs_real") then
                enable "path_stairs"
            end
        end
    },
    obj {
        nam = "#люк";
        act = function(s)
            if s.is_closed then
                p "Я потянул за ручку, но открыть люк у меня не вышло."
            else
                p "Люк открыт, крышка лежит сбоку."
            end
        end;
        used = function(s,w)
            if w^"РазводнойКлюч" then
                if s.is_closed then
                    p "Используя разводной ключ как рычаг, я приподнял люк и отодвинул его в сторону."
                    s.is_closed = false
                    enable "path_engineroom"
                else
                    p "Люк уже открыт."
                end
                return
            end
            return false
        end;
        is_closed = true;
    },
    obj {
        nam = "#glasscube";
        act = function(s)
            p "Под стеклом лежали несколько страниц отпечатанного на машинке текста. Содержание документа я прекрасно помнил -- ещё бы, ведь я был одним из тех, кто его составлял..."
        end;
        used = function (s,w)
            if w^"РазводнойКлюч" then
                p "Раздался звон разбитого стекла, и осколки разлетелись по полу."
                s.is_broken = true
                return
            end
            return false
        end;
        --
        is_broken = false;
    },
    obj {
        nam = "#стекло";
        act = function(s)
            if have("Стекло") then 
                p "В осколках отражается желтый свет ламп."
            else
                p "Я осторожно подобрал осколок с пола."
                take "Стекло"
            end
        end;
    },
    obj {
        nam = "#бумага";
        act = function(s)
            p "Я вытащил из-под осколков листы, сложил их и спрятал в карман."
            take "Бумаги"
        end;
    }
}



--[[
#############################################################################################################
]]--

obj {
    nam = "Изолента";
    dsc = "На полу лежит {моток изоленты}, слегка присыпанный пылью.";
    inv = "Моток синей изоленты.";
    tak = "Я подобрал изоленту.";
}


room {
    nam = "engineroom";
    disp = "Служебное помещение";
    way = {
        path { "В хранилище", "storage" }
    };
    decor = function(s)
        pr([[
        Тесное небольшое помещение. От гула машин, поддерживающих работу комплекса, звенит в ушах.^
        Рядом с лестницей, ведущей наверх, находится {#пульт|пульт управления}.
        Справа от пульта виден {#вентиль|вентиль} системы управления гермодверью хранилища]])
        if _"#вентиль".is_hot then
            p "."
        else
            p ", на который наброшена кожаная {#взять_обшивку|обшивка} капсулы."
        end
    end;
}:with{
    'Изолента',
    obj {
        nam = "#пульт";
        act = function(s)
            p "Большая часть индикаторов на пульте горит красным. Похоже, долго эти машины не протянут."
        end
    },
    obj {
        nam = "#вентиль";
        act = function(s)
            if s.is_hot then
                p "Я схватил вентиль, но тут же отдернул руку - раскаленный металл больно обжёг ладони."
            elseif s.is_active then
                p "Гермодверь уже открыта."
            else
                p "Я прокрутил вентиль до упора. Что-то загрохотало в темноте за переплетением труб, и вскоре сверху послышался скрежет открывающейся гермодвери."
                s.is_active = true
                _"storage".is_open = true;
            end
        end;
        used = function(s,w)
            if w^"Обшивка" then
                p "Я набросил кожаную обшивку на вентиль."
                place("Обшивка","tmp");
                s.is_hot = false
                return
            end
            if w^"РазводнойКлюч" then
                if s.is_hot then
                    p "Я попытался провернуть вентиль ключом, но ничего не вышло - мешал жар от металла."
                else
                    p "Через обшивку ухватить вентиль ключом у меня не вышло - слишком толстая."
                end
                return
            end
            return false
        end;
        --
        is_hot = true;
        is_active = false;
    },
    obj {
        nam = "#взять_обшивку";
        act = function()
            p "Осторожно, чтобы не обжечься, я снял обшивку с вентиля."
            take "Обшивка"
            _"#вентиль".is_hot = true
        end
    },
}


--[[
#############################################################################################################
]]--


room {
    nam = "stairs";
    disp = "Лестничная шахта";
    way = { path { "В хранилище", "storage" },
            path {"path_hall", "Вверх", "cutscene2" }:disable() };
    decor = function(s)
        p([[Луч света из щели дверей хранилища освещает небольшую комнату. Сверху из лестничного пролета виден дневной свет.^
        Здесь очень {#холод|холодно}.
        ]])
    end;
}:with{
    obj {
        nam = "#холод";
        act = function(s)
            if is_warm then
                p "Теперь, когда я утеплил свою одежду обшивкой, можно подняться вверх..."
            else 
                p "Если я попытаюсь выйти наружу в такую погоду, то неизбежно замерзну..."
            end
        end
    },
}

room {
    nam = "cutscene2";
    noinv = true;
    disp = false;
    pic = "gfx/up.png";
    decor = function(s)
        p(fmt.em([[
Я поднялся по лестнице и вошел в большой круглый зал. Тот самый, в котором нас провожали в долгий путь.^
Зал был абсолютно пуст и, очевидно, давно заброшен. Всё, что представляло хоть малейшую ценность, растащили. Мозаика на стенах местами осыпалась, в потолке зияли дыры, через которые в зал проникал дневной свет.^
        ]]))
        pn(fmt.c("{#next|...}"))
    end;
}:with{
    obj { nam = "#next"; act = function() walk "hall" end }
}






--[[
#############################################################################################################
]]--


room {
    nam = "hall";
    noinv = true;
    disp = "Галерея";
    enter = function(s)
        p "Я вышел из зала на круговую галерею. И был поражён увиденным."
    end;
    way = { path {"path_wind", "К ветрякам", "cutscene_end" }:disable(),
            path {"path_city", "К городу", "cutscene_end" }:disable() };
    decor = function(s)
        p [[
        За огромными окнами галереи открывался потрясающий вид. На холмах, слегка покрытых лесом, кое-где лежал снег.^
        И там, среди холмов, до самого горизонта стояли огромные {#ветряки|ветряки}, их лопасти медленно вращались. А рядом сияли огни небольшого {#город|города}.^
        ]]
    end;
}:with{
    obj {
        nam = "#ветряки";
        act = function(s)
            p "Я насчитал около десятка ветряков. Как будто картина из фантастического романа."
            enable "path_wind"
        end
    },
    obj {
        nam = "#город";
        act = function(s)
            p "Город сильно изменился за эти годы. Появились новые кварталы со множеством высотных зданий."
            enable "path_city"
        end
    }
}


room {
    nam = "cutscene_end";
    noinv = true;
    disp = false;
    disp = false;
    pic = "gfx/monument.png";
    decor = function(s)
        p(fmt.em([[
Получасовой спуск оказался утомителен для меня, и я остановился отдохнуть возле поросшего травой монумента.^
На вершине холма виднелось здание, в котором я провел столько лет. Но теперь причина, по которой оно оказалось заброшенным, больше меня не беспокоила - то, что я увидел сверху, давало мне надежду.^
        ]]))
        pn(fmt.c("{#next|...}"))
    end
}:with{
    obj { nam = "#next"; act = function() walk "finale" end }
}

room {
    nam = "finale";
    disp = false;
    noinv = true;
    pic = "gfx/finale.png";
    decor = function(s)
        p(fmt.c(
        "Надежду увидеть своими глазами то, ^ради чего проделал этот долгий и сложный путь. ^^"..
        s.phrases[s.phrase_num]
        ))
    end;
    enter = function() 
        fmt.para = false
    end;
    phrase_num = 1;
    phrases = {"{#endsw|Будущее.}", "{#endsw|Светлое будущее.}", fmt.b("Светлое коммунистическое будущее.")};
}:with{
    obj {
        nam = "#endsw";
        act = function(s) 
            if _"finale".phrase_num < 3 then
                _"finale".phrase_num = _"finale".phrase_num + 1
            end
        end;
    }
};

-- специальная комната, чтобы временно хранить объекты
room {nam = "tmp"}
