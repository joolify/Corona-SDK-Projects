--*********************************************************************************************
--
-- ====================================================================
-- Corona SDK Calendar Sample Code
-- ====================================================================
--
-- File: main.lua
--
-- Version 1.0
--
-- Made by joelwe
-- Contact: support[at]joolify.se

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
-- Our scene
function scene:createScene( event )
    local group = self.view
    
    local date = os.date( "*t" )
    local curMonth = date.month
    local curYear = date.year
    
    -- Creates a background
    local function create_bg()
        local background = display.newImage( "assets/background.png", true )
        group:insert( background )
    end
    
    --Returns name of month[i]
    local get_month_name =
    {
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    }
    
    --Returns short name of month[i]
    local get_short_month_name =
    {
        "jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"
    }
    
    --Returns days in a month, including for leap year
    local function get_days_in_month(month, year)
        local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }   
        local d = days_in_month[month]
        
        --Check for leap year
        if (month == 2) then
            if year%4==0 and (year%100~=0 or year%400==0) then
                d = 29
            end
        end
        
        return d  
    end
    
    --Returns day of week
    local get_day_of_week =
    {
        "sun", "mon", "tue", "wed", "thu", "fri", "sat"
    }
    
    --Get the first day of the month
    local function get_start_day( cur_month, cur_year )
        local temp = os.time{year = cur_year, month=cur_month, day=1}
        return tonumber(os.date("%w", temp))
    end
    
    --Get the last day of the month
    local function get_end_day( cur_month, cur_year )
        return tonumber(get_days_in_month(cur_month, curYear))
    end
    
    -- Creates the calendar
    local function create_calender( year, month )
        
        --Create previous month
        local prevMonth = month - 1
        local prevYear = year
        if prevMonth < 1 then 
            prevMonth = 12
            prevYear = prevYear - 1
        end
        local prevDays = false
        local prevStartDay
        local prevEndDay
        
        --Create selected month
        local selMonth = month
        local selYear = year
        local selDays = false
        local selStartDay = get_start_day( month, year ) + 1 --Adds 1 because table index starts at 1.
        local selEndDay = get_end_day( month, year ) 
        
        --Create next month
        local nextMonth = month + 1
        local nextYear = year
        if nextMonth == 13 then
            nextMonth = 1
            nextYear = nextYear + 1
        end
        local nextDays = false
        local nextStartDay = 1
        local nextEndDay
        
        --Check if there is a previous month on the screen
        local daysToSelMonth = 1 - selStartDay
        if daysToSelMonth < 0 then
            prevDays = true
        end
        
        if prevDays then
            daysToSelMonth = daysToSelMonth + 1
            prevEndDay = get_days_in_month( prevMonth, year ) 
            prevStartDay = prevEndDay + daysToSelMonth
        end
        
        --Creates a "calender box" which shows selected month, year and the weekdays.
        local calBox = display.newRect( 0, 32, display.contentWidth, 47 )
        calBox:setFillColor( 0, 0, 0 )
        calBox.alpha = 0.4
        group:insert( calBox )
        
        --Selected month name
        local monthName = display.newText( get_month_name[selMonth], 0, 0, 0, 0, native.systemFont, 20 )
        monthName:setTextColor( 255, 255, 255 )
        monthName:setReferencePoint(display.CenterLeftReferencePoint)
        monthName.x = 5
        monthName.y = calBox.y - 5
        group:insert( monthName )
        
        --Selected year name
        local yearName = display.newText( year, 0, 0, 0, 0, native.systemFont, 20 )
        yearName:setTextColor( 255, 255, 255 )
        yearName:setReferencePoint(display.CenterLeftReferencePoint)
        yearName.x = display.contentWidth - yearName.contentWidth
        yearName.y = calBox.y - 5
        group:insert( yearName )
        
        
        --Create calender days
        local calDay 
        local calMonth
        local calYear
        local calEnd
        local calFirst = false
        local calWhatMonth
        local calRows = 5
        if 36 - selEndDay- selStartDay < 0 then --If the selected month starts on a fri/sat then expand the rows.
            calRows = 6
        end
        
        --Check if there is a previous month for the selected month
        if prevDays then
            calDay = prevStartDay
            calMonth = prevMonth
            calYear = prevYear
            calEnd = prevEndDay
            calFirst = true
            calWhatMonth = 1
        else 
            calDay = selStartDay
            calMonth = selMonth
            calYear = selYear
            calEnd = selEndDay
            calFirst = true
            calWhatMonth = 2
        end
        
        local x = 0
        local y = calBox.y + calBox.contentHeight*0.5
        
        --Create a 5-6*7 grid.
        for j = 1, calRows do --5-6 rows
            for i = 1, 7 do --7 columns
                --Creates a box for each day.
                local dayBox 
                
                --Change height depending on amount of rows.
                if calRows == 5 then
                    dayBox = display.newRect( x, y, display.contentWidth/7, 66 )
                else
                    dayBox = display.newRect( x, y, display.contentWidth/7, 55 )
                end
                
                if calWhatMonth ~= 2 then --Fills the days which aren't the selected month with a different color 
                    dayBox:setFillColor( 0, 204, 204, 255 )
                elseif i == 1 or i == 7 then --Fills weekend days with a different color
                    dayBox:setFillColor( 0, 255, 255, 255 )
                else 
                    dayBox:setFillColor( 255, 255, 255 )
                end
                
                dayBox.alpha = 0.4
                group:insert( dayBox )
                
                local calDayText
                --If it's the first day of the month, show the name of the month.
                if calFirst then
                    calDayText = calDay .. " " .. get_short_month_name[calMonth]
                    calFirst = false
                else
                    calDayText = calDay
                end
                
                --A text representing each day nr. 
                local dayText
                
                if calDay == date.day and calMonth == date.month and calYear == date.year then --Bolds the day nr if it's today.
                    dayText = display.newText( calDayText, 0, 0, 0, 0, native.systemFontBold, 10 )
                    dayText:setTextColor( 255, 51, 51, 255 )
                else
                    dayText = display.newText( calDayText, 0, 0, 0, 0, native.systemFont, 10 )
                    dayText:setTextColor( 0, 0, 0 )
                end
                
                dayText:setReferencePoint(display.CenterLeftReferencePoint)
                dayText.x = x + 3
                dayText.y = y + 7
                group:insert( dayText )
                
                --If it's the end of the month, stop showing day numbers. 
                if calDay == calEnd then
                    if calWhatMonth == 1 then
                        calDay = 1
                        calMonth = selMonth
                        calYear = selYear
                        calEnd = selEndDay
                        calFirst = true
                        calWhatMonth = 2 
                    elseif calWhatMonth == 2 then
                        calDay = 1
                        calMonth = nextMonth
                        calYear = nextYear
                        calEnd = nextEndDay
                        calFirst = true
                        calWhatMonth = 3
                    end
                else
                    calDay = calDay + 1
                end
                
                --Print out the day names on the calBox. 
                if j == 1 then
                    local dayText = display.newText( get_day_of_week[i], 0, 0, 44, 0, native.systemFont, 14 )
                    dayText.x = dayBox.x + dayBox.contentWidth * 0.5 - dayText.contentWidth * 0.25
                    dayText.y = dayBox.y  - dayBox.contentHeight * 0.5 - dayText.contentHeight * 0.5
                    group:insert( dayText )
                end
                
                --Create horizontal frames
                if j ~= 1 then
                    local frameBottom = display.newRect( x, y, dayBox.contentWidth+1, 1 )
                    frameBottom:setFillColor( 0, 0, 0 )
                    frameBottom.alpha = 1
                    group:insert( frameBottom )
                end
                
                --Create vertical frames
                if i ~= 1 then
                    local frameRight = display.newRect( x, y, 1, dayBox.contentHeight )
                    frameRight:setFillColor( 0, 0, 0 )
                    frameRight.alpha = 1
                    group:insert( frameRight )
                end
                
                x = x + display.contentWidth/7
                
            end
            
            if calRows == 5 then
                y = y + 66
            else
                y = y + 55
            end
            x = 0
        end
    end
    
    local jump_to_prev_month
    local jump_to_next_month
    
    --Creates buttons for going back and forth in months. 
    local function create_buttons()
        
        local prevButton = widget.newButton
        {
            left = 15,
            top = display.contentHeight - 70,
            width = 80,
            height = 40,
            label = "<<",
            onRelease = jump_to_prev_month,
        }
        prevButton.xScale = 0.5
        prevButton.yScale = 0.5
        
        group:insert( prevButton )
        
        local nextButton = widget.newButton
        {
            left = display.contentWidth - 100,
            top = display.contentHeight - 70,
            width = 80,
            height = 40,
            label = ">>",
            onRelease = jump_to_next_month,
        }
        nextButton.xScale = 0.5
        nextButton.yScale = 0.5
        
        group:insert( nextButton )
    end
    
    --Remove objects
    local function remove_objects()
        for i=group.numChildren,1,-1 do
            local child = group[i]
            child.parent:remove( child )
            child = nil
        end
    end
    
    --Go to the previous month.
    function jump_to_prev_month()
        --Remove all objects
        remove_objects()
        
        --Set the cal month back to the previous month. 
        curMonth = curMonth - 1
        
        --If the month is before January, go back to previous year. 
        if curMonth < 1 then
            curMonth = 12
            curYear = curYear - 1
        end
        
        --Create background, buttons and calender. 
        create_bg()
        create_buttons()
        create_calender( curYear, curMonth )
    end
    
    --Go to the next month. 
    function jump_to_next_month()
        --Remove all objects
        remove_objects()
        
        --Set the cal month back to the next month. 
        curMonth = curMonth + 1
        --If the month is after December, go to the next year. 
        if curMonth > 12 then
            curMonth = 1
            curYear = curYear + 1
        end
        
        --Create background, buttons and calender. 
        create_bg()
        create_buttons()
        create_calender( curYear, curMonth )
    end
    
    --Create main 
    local function main()
        --Create background, buttons and calender. 
        create_bg()
        create_buttons()
        create_calender( curYear, curMonth  )
    end
    main()
    
end

scene:addEventListener( "createScene" )

return scene