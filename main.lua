vector = {}
function vector.subtract(vec1, vec2)
    if not vec1 or not vec2 then
        return
    end
    local x = vec1.x - vec2.x
    local y = vec1.y - vec2.y
    return x, y
end
function vector.distance(startpos, endpos)
    if not startpos or not endpos then
        return
    end

    local dist = math.abs(math.sqrt(((startpos.x - endpos.x)*(startpos.x - endpos.x)) + ((startpos.y - endpos.y)*(startpos.x - endpos.x))))
    return dist
end
function vector.is_between(a, b, c, p)
    if not a or not b or not c or not p then
        return
    end
    local area = (a.x*(b.y - c.y) + b.x*(c.y - a.y) + c.x*(a.y - b.y))/2
    local a1 = math.abs((p.x*(a.y - b.y) + a.x*(b.y - p.y) + b.x*(p.y - a.y))/2)
    local a2 = math.abs((p.x*(b.y - c.y) + b.x*(c.y - p.y) + c.x*(p.y - b.y))/2)
    local a3 = math.abs((p.x*(a.y - c.y) + a.x*(c.y - p.y) + c.x*(p.y - a.y))/2)

    if a1 + a2 + a3 == area then
        return true
    else
        return false
    end
end
function vector.get_vector_to(startpos, endpos)
    if not startpos or not endpos then
        return
    end
    local x, y = vector.subtract(endpos, startpos)
    return x, y
end
function move_on_keypress(xspeed, yspeed)
    keys = {}
    keys.up = love.keyboard.getKeyFromScancode("w")
    keys.down = love.keyboard.getKeyFromScancode("s")
    keys.left = love.keyboard.getKeyFromScancode("a")
    keys.right = love.keyboard.getKeyFromScancode("d")

    if love.keyboard.isScancodeDown(keys.up) then
        objects.player.velocity.y = -yspeed
    elseif love.keyboard.isScancodeDown(keys.down) then
        objects.player.velocity.y = yspeed
    else
        objects.player.velocity.y = 0
    end
    if love.keyboard.isScancodeDown(keys.left) then
        objects.player.velocity.x = -xspeed
    elseif love.keyboard.isScancodeDown(keys.right) then
        objects.player.velocity.x = xspeed
    else
        objects.player.velocity.x = 0
    end

    objects.player.body:setLinearVelocity(objects.player.velocity.x, objects.player.velocity.y)
    return objects.player.velocity.x, objects.player.velocity.y
end

function hitter_mob(objects, bot_count)
    if not objects or not bot_count then
        return
    end

    if time > 3 then
        if objects.melee_bots.count < 5 then
            for x = 2 * pixel_size, win_dim.x - pixel_size * 3, pixel_size*2 do
                for y = 2 * pixel_size, win_dim.y - pixel_size * 5, pixel_size*2 do
                    local num = math.random(1, 40)
                    --print("num: " .. num)
                    local player_pos = {}
                    player_pos.x, player_pos.y = objects.player.body:getPosition()
                    if num == 1 and objects.melee_bots.count <= wave_limit * wave and vector.distance({x = x, y = y}, player_pos) > 100 then
                        objects.melee_bots[objects.melee_bots.count] = {}
                        objects.melee_bots[objects.melee_bots.count].body = love.physics.newBody(world, x, y, "dynamic")
                        objects.melee_bots[objects.melee_bots.count].shape = love.physics.newRectangleShape(40, 40)
                        objects.melee_bots[objects.melee_bots.count].fixture = love.physics.newFixture(objects.melee_bots[objects.melee_bots.count].body, objects.melee_bots[objects.melee_bots.count].shape)
                        objects.melee_bots[objects.melee_bots.count].img = love.graphics.newImage("/gfx/wolf.png")
                        objects.melee_bots[objects.melee_bots.count].pos = {x = x, y = y}
                        --love.graphics.draw(objects.melee_bots[bot_count].img, x, y)
                        objects.melee_bots.count = objects.melee_bots.count + 1
                        --print(objects.melee_bots.count)

                    end
                end
            end
        end
        time = 0
        return time
    end

    for i = 0, objects.melee_bots.count do
        if objects.melee_bots[i] then
            local player_pos = {}
            player_pos.x, player_pos.y = objects.player.body:getPosition()
            local vel = {}
            --vel.x, vel.y = objects.melee_bots[i].body:getLinearVelocity()
            vel.x, vel.y = objects.melee_bots[i].body:getPosition()
            vel.x, vel.y = vector.get_vector_to(vel, player_pos)
            --objects.melee_bots[i].dir = math.rad(math.random(-360, 360))
            
            --print(vector.distance(vel, player_pos))
            --if vector.distance(vel, player_pos) < 200 then
                --print("attack player")
                objects.melee_bots[i].dir = math.atan2(vel.y, vel.x) + math.rad(-90)
            --end
            --print("move!")
            objects.melee_bots[i].body:setLinearVelocity(vel.x + math.cos(objects.melee_bots[i].dir)*5, vel.y + math.sin(objects.melee_bots[i].dir)*5)
        end
    end
end
function level_reset()
    objects.player = {}
    objects.player.body = love.physics.newBody(world, 100, 100, "dynamic")
    objects.player.shape = love.physics.newRectangleShape(40, 40)
    objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape)
    objects.player.img = love.graphics.newImage("/gfx/wolf.png")
    objects.player.pos = {x = 100, y = 100}
    objects.player.velocity = {x = 0, y = 0}

    objects.melee_bots = {}
    objects.melee_bots.count = 0

    objects.fire_ball = {}
    objects.fire_ball.count = 0
    
    mouse_pos = {}

    time = 0
    vec = {}
    img_dim = {}
    img_dim.x, img_dim.y = objects.player.img:getDimensions()
    rot = 0
    bot_count = 0
    touching = nil
    restart_level = false

end
function set_defaults()
    menu_font = love.graphics.newFont("/fonts/font_karma.ttf", 50)
    hud_font = love.graphics.newFont("/fonts/font_karma.ttf", 30)

    win_size = 32
    pixel_size = 23
    win_dim = {x = win_size * pixel_size, y = win_size * pixel_size}
    love.window.setMode(win_dim.x, win_dim.y)
    
    world = love.physics.newWorld(1, 1, true)

    objects = {}

    objects.barriers = {}

    objects.barriers.bottom = {}
    objects.barriers.bottom.body = love.physics.newBody(world, win_dim.x/2, pixel_size*(win_size-1))
    objects.barriers.bottom.shape = love.physics.newRectangleShape(650, pixel_size*3)
    objects.barriers.bottom.fixture = love.physics.newFixture(objects.barriers.bottom.body, objects.barriers.bottom.shape)

    objects.barriers.top = {}
    objects.barriers.top.body = love.physics.newBody(world, win_dim.x/2, 1)
    objects.barriers.top.shape = love.physics.newRectangleShape(650, pixel_size)
    objects.barriers.top.fixture = love.physics.newFixture(objects.barriers.top.body, objects.barriers.top.shape)

    objects.barriers.left = {}
    objects.barriers.left.body = love.physics.newBody(world, 1, win_dim.y/2)
    objects.barriers.left.shape = love.physics.newRectangleShape(pixel_size, 650)
    objects.barriers.left.fixture = love.physics.newFixture(objects.barriers.left.body, objects.barriers.left.shape)

    objects.barriers.right = {}
    objects.barriers.right.body = love.physics.newBody(world, win_size * pixel_size, win_dim.y/2)
    objects.barriers.right.shape = love.physics.newRectangleShape(pixel_size, 650)
    objects.barriers.right.fixture = love.physics.newFixture(objects.barriers.right.body, objects.barriers.right.shape)

    level_reset()

    triangle = {a = {x = 0, y = 0}, b = {x = 10, y = 30}, c = {x = 20, y = 0}, p = {x = 10, y = 15}}
    foo = vector.is_between(triangle.a, triangle.b, triangle.c, triangle.p)
    print(foo)


    cursor = love.mouse.newCursor("/gfx/cursor.png", 0, 0)
    love.mouse.setCursor(cursor)
    brick = love.graphics.newImage("/gfx/brick.png")
    quad_sheet = love.graphics.newQuad(0, 0, 23, 15, objects.player.img:getDimensions())

    wave_time = 10
    wave_limit = 2
    wave = 1
    has_started = false
    has_exited = false
    lives = 5
    timer = 0
    score = 0

    btn_click = love.audio.newSource("/sounds/click.wav", "static")
    bg_music = love.audio.newSource("/sounds/bg_music.mp3", "static")
    played = 0

    menu_btn = {}

    menu_btn.start = {}
    menu_btn.start.offset = 100
    menu_btn.start.pos = {x = win_dim.x/2 - pixel_size*5, y = win_dim.y/2 - menu_btn.start.offset}
    menu_btn.start.played = 0

    menu_btn.exit = {}
    menu_btn.exit.offset = 40
    menu_btn.exit.pos = {x = win_dim.x/2 - pixel_size*5, y = win_dim.y/2 - menu_btn.exit.offset}
    menu_btn.exit.played = 0
end
function love.load()
    menu_font = love.graphics.newFont("/fonts/font_karma.ttf", 50)
    hud_font = love.graphics.newFont("/fonts/font_karma.ttf", 30)

    win_size = 32
    pixel_size = 23
    win_dim = {x = win_size * pixel_size, y = win_size * pixel_size}
    love.window.setMode(win_dim.x, win_dim.y)
    
    world = love.physics.newWorld(1, 1, true)

    objects = {}

    objects.barriers = {}

    objects.barriers.bottom = {}
    objects.barriers.bottom.body = love.physics.newBody(world, win_dim.x/2, pixel_size*(win_size-1))
    objects.barriers.bottom.shape = love.physics.newRectangleShape(650, pixel_size*3)
    objects.barriers.bottom.fixture = love.physics.newFixture(objects.barriers.bottom.body, objects.barriers.bottom.shape)

    objects.barriers.top = {}
    objects.barriers.top.body = love.physics.newBody(world, win_dim.x/2, 1)
    objects.barriers.top.shape = love.physics.newRectangleShape(650, pixel_size)
    objects.barriers.top.fixture = love.physics.newFixture(objects.barriers.top.body, objects.barriers.top.shape)

    objects.barriers.left = {}
    objects.barriers.left.body = love.physics.newBody(world, 1, win_dim.y/2)
    objects.barriers.left.shape = love.physics.newRectangleShape(pixel_size, 650)
    objects.barriers.left.fixture = love.physics.newFixture(objects.barriers.left.body, objects.barriers.left.shape)

    objects.barriers.right = {}
    objects.barriers.right.body = love.physics.newBody(world, win_size * pixel_size, win_dim.y/2)
    objects.barriers.right.shape = love.physics.newRectangleShape(pixel_size, 650)
    objects.barriers.right.fixture = love.physics.newFixture(objects.barriers.right.body, objects.barriers.right.shape)

    level_reset()

    triangle = {a = {x = 0, y = 0}, b = {x = 10, y = 30}, c = {x = 20, y = 0}, p = {x = 10, y = 15}}
    foo = vector.is_between(triangle.a, triangle.b, triangle.c, triangle.p)
    print(foo)


    cursor = love.mouse.newCursor("/gfx/cursor.png", 0, 0)
    love.mouse.setCursor(cursor)
    brick = love.graphics.newImage("/gfx/brick.png")
    quad_sheet = love.graphics.newQuad(0, 0, 23, 15, objects.player.img:getDimensions())

    wave_time = 10
    wave_limit = 2
    wave = 1
    has_started = false
    has_exited = false
    lives = 5
    timer = 0
    click_time = 0
    score = 0

    btn_click = love.audio.newSource("/sounds/click.wav", "static")
    bg_music = love.audio.newSource("/sounds/bg_music.mp3", "static")
    played = 0

    menu_btn = {}

    menu_btn.start = {}
    menu_btn.start.offset = 100
    menu_btn.start.pos = {x = win_dim.x/2 - pixel_size*5, y = win_dim.y/2 - menu_btn.start.offset}
    menu_btn.start.played = 0

    menu_btn.exit = {}
    menu_btn.exit.offset = 40
    menu_btn.exit.pos = {x = win_dim.x/2 - pixel_size*5, y = win_dim.y/2 - menu_btn.exit.offset}
    menu_btn.exit.played = 0
end

function love.update(dt)
    world:update(dt)

    love.audio.play(bg_music)

    if has_started == false then
        if love.mouse.isDown(1) then
            mouse_pos.x, mouse_pos.y = love.mouse.getPosition()
            for _, data in pairs(menu_btn) do
                if (mouse_pos.y > data.pos.y and mouse_pos.y < data.pos.y + 50) and (mouse_pos.x > data.pos.x and mouse_pos.x < data.pos.x + 200) then
                    love.audio.play(btn_click)

                    if data == menu_btn.start then
                        has_started = true
                    end
                    if data == menu_btn.exit then
                        love.event.quit()
                    end
                end
            end
        end

    else

        if lives <= 0 then
            set_defaults()
        end

        timer = timer + dt
        if timer >= wave_time then
            restart_level = true
            wave = wave + 1
            timer = 0
        end
        for i = 0, objects.melee_bots.count do
            if objects.melee_bots[i] then
                touching = objects.player.body:isTouching(objects.melee_bots[i].body)
                if touching == true then
                    lives = lives - 1
                    restart_level = true
                end
            end
        end
        if restart_level == true then
            objects.player.body:destroy()
            for i = 0, objects.melee_bots.count do
                if objects.melee_bots[i] then
                    objects.melee_bots[i].body:destroy()
                end
            end
            level_reset()
        end

        if love.mouse.isDown(1) then
            if not (love.timer.getTime() - click_time < 1) then

            click_time = love.timer.getTime()
            local player_pos = {}
            player_pos.x, player_pos.y = objects.player.body:getPosition()
            local vel = {}
            vel.x, vel.y = love.mouse.getPosition()
            vel.x, vel.y = vector.get_vector_to(objects.player.pos, vel)

            objects.fire_ball.count = objects.fire_ball.count + 1

            objects.fire_ball[objects.fire_ball.count] = {}
            objects.fire_ball[objects.fire_ball.count].body = love.physics.newBody(world, player_pos.x + vel.x/3, player_pos.y + vel.y/3, "dynamic")
            objects.fire_ball[objects.fire_ball.count].shape = love.physics.newRectangleShape(40, 40)
            objects.fire_ball[objects.fire_ball.count].fixture = love.physics.newFixture(objects.fire_ball[objects.fire_ball.count].body, objects.fire_ball[objects.fire_ball.count].shape)
            objects.fire_ball[objects.fire_ball.count].img = love.graphics.newImage("/gfx/fireball.png")
            objects.fire_ball[objects.fire_ball.count].pos = {}
            objects.fire_ball[objects.fire_ball.count].timer = love.timer.getTime()
            --objects.fire_ball[objects.fire_ball.count].dir = (math.atan2(vel.y, vel.x) + math.pi) + math.rad(90)
            objects.fire_ball[objects.fire_ball.count].body:setLinearVelocity(vel.x*5, vel.y*5)
            end
        end

        for i = 0, objects.fire_ball.count do
            if objects.fire_ball[i] then
                local time_dif = love.timer.getTime() - objects.fire_ball[i].timer
                if time_dif > 1 then
                    objects.fire_ball[i].body:destroy()
                    objects.fire_ball[i] = nil
                    --print(objects.fire_ball.count)
                    objects.fire_ball.count = objects.fire_ball.count - 1
                end
            end
        end
        for i = 0, objects.fire_ball.count do
            if objects.fire_ball[i] then
                for v = 0, objects.melee_bots.count do
                    if objects.melee_bots[v] then
                        if objects.fire_ball[i] then
                        if objects.fire_ball[i].body:isTouching(objects.melee_bots[v].body) then
                            objects.fire_ball[i].body:destroy()
                            objects.melee_bots[v].body:destroy()
                            objects.fire_ball[i] = nil
                            objects.melee_bots[v] = nil
                            objects.fire_ball.count = objects.fire_ball.count - 1
                            objects.melee_bots.count = objects.melee_bots.count - 1
                            score = score + 1
                        end
                    end
                    end
                end
            end
        end

        hitter_mob(objects, bot_count)

        if love.mouse.isDown(1) then
            mouse_pos.x, mouse_pos.y = love.mouse.getPosition()
        end
        move_on_keypress(350, 350)

        vec.x, vec.y = love.mouse.getPosition()
        vec.x, vec.y = vector.get_vector_to({x = objects.player.pos.x , y = objects.player.pos.y}, vec)
        --print(vec.x, vec.y)
        rot = (math.atan2(vec.y, vec.x) + math.pi) + math.rad(90)
        --print(rot)
        objects.player.pos.x, objects.player.pos.y = objects.player.body:getPosition()
    end
end

function love.draw()
    if has_started == false then
        love.graphics.setFont(menu_font)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("CYBERWOLF", win_dim.x/2 - pixel_size*6, win_dim.y/2 - 250)
        love.graphics.printf("START", menu_btn.start.pos.x, menu_btn.start.pos.y, 200, "center")
        love.graphics.printf("EXIT", menu_btn.exit.pos.x, menu_btn.exit.pos.y, 200, "center")
        love.graphics.setColor(1, 1, 1, 1)

        mouse_pos.x, mouse_pos.y = love.mouse.getPosition()
        for _, data in pairs(menu_btn) do
            if (mouse_pos.y > data.pos.y and mouse_pos.y < data.pos.y + 50) and (mouse_pos.x > data.pos.x and mouse_pos.x < data.pos.x + 200) then
                love.graphics.draw(objects.player.img, win_dim.x/2, win_dim.y/2-data.offset, 0, 1.5, 1.5, img_dim.x/pixel_size + 120, img_dim.y/pixel_size) 
                if data.played == 0 then
                    love.audio.play(btn_click)
                    data.played = 1
                end
            else
                data.played = 0
            end
        end
    else
        love.graphics.setFont(hud_font)

        dt = love.timer.step()
        time = time + dt
        --print(time)
        --hitter_mob(objects, bot_count)

        for i = 0, win_size do --draw top barrier
            love.graphics.draw(brick, i * pixel_size, 0)
        end
        for v = 0, 3 do --draw bottom barrier
            for i = 0, win_size do
                love.graphics.draw(brick, i * pixel_size, win_dim.y - pixel_size * v)
            end
        end
        for i = 0, win_size do --draw left barrier
            love.graphics.draw(brick, 0, i * pixel_size)
        end
        for i = 0, win_size do --draw right barrier
            love.graphics.draw(brick, win_dim.x - pixel_size, i * pixel_size)
        end

        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("Score: " .. score, pixel_size, win_dim.y - pixel_size * 3)
        love.graphics.print("Lives: " .. lives, pixel_size * 11, win_dim.y - pixel_size * 3)
        love.graphics.print("Wave: " .. wave, pixel_size * 22, win_dim.y - pixel_size * 3)

        love.graphics.setColor(1, 1, 1, 1)

        for i = 0, objects.melee_bots.count do
            if objects.melee_bots[i] then
            --print(objects.melee_bots.count)

            local rot = (math.atan2(objects.melee_bots[i].pos.y, objects.melee_bots[i].pos.x) + math.pi) + math.rad(90)

            objects.melee_bots[i].pos.x, objects.melee_bots[i].pos.y = objects.melee_bots[i].body:getPosition()
            love.graphics.draw(objects.melee_bots[i].img, objects.melee_bots[i].pos.x, objects.melee_bots[i].pos.y, objects.melee_bots[i].dir, 1, 1, img_dim.x/2, img_dim.y/2)
            end
        end
        for i = 0, objects.fire_ball.count do
            if objects.fire_ball[i] then
                
                objects.fire_ball[i].pos.x, objects.fire_ball[i].pos.y = objects.fire_ball[i].body:getPosition()
                love.graphics.draw(objects.fire_ball[i].img, objects.fire_ball[i].pos.x, objects.fire_ball[i].pos.y, 0, 1, 1, img_dim.x/2, img_dim.y/2)
            end
        end

        love.graphics.draw(objects.player.img, objects.player.pos.x, objects.player.pos.y, rot, 1, 1, img_dim.x/2, img_dim.y/2)
    end
end