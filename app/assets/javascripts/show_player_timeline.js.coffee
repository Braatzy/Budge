translate = (x, y) -> "translate(" + x + "," + y + ")"

chart_margin=28
dot_radius_checkin=4
dot_radius_msg=3.5
checkin_size=100

parse_time = d3.time.format.iso.parse 
parse_date = d3.time.format("%Y-%m-%d").parse
show_time = d3.time.format("%Y-%m-%d %H:%M")

unhighlight_rows = () -> $('tr').removeClass('highlighted')
highlight_level = (level_id)->
    unhighlight_rows()
    $("#level_attempt#{level_id}").toggleClass('highlighted')
    $(".message#{level_id}").toggleClass('highlighted')
    $(".checkin#{level_id}").toggleClass('highlighted')
    currently_highlighted_id=level_id
highlight_row = (id,level_id,type)->
    unhighlight_rows()
    $("#level_attempt#{level_id}").toggleClass('highlighted')
    $("##{type}#{id}").toggleClass('highlighted')
    

make_player_timeline = (checkins_info,budges_info,player_messages_info,number_levels,range_time,container_id,use_week_ticks=true,screen_width=800,screen_height=300) ->
    # console.log budges_info
    # console.log checkins_info
    # console.log player_messages_info
    # console.log number_levels
    # console.log range_time

    # redraw = () -> 
    #     # console.log("here", d3.event.translate, d3.event.scale)
    #     # console.log('command',"translate(#{d3.event.translate}) scale(#{d3.event.scale})" )
    #     # svg.attr("transform", "translate(#{d3.event.translate}) scale(#{d3.event.scale})" )
    #     return
    # @back_to_original=back_to_original=()->svg.attr("transform", translate(chart_margin,0) ) #translate(0,0) scale(0)
        
    w = screen_width - 1*chart_margin
    h = screen_height - 1*chart_margin
    x = d3.time.scale().range([ 0, w ])
    y = d3.scale.linear().domain([0,number_levels]).range([ h, 20 ])
        
    dom_all ={x: range_time.map((t)->parse_time(t)), y: [0,number_levels]}
    x.domain(dom_all.x)
    y.domain(dom_all.y)
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    svg = d3.select("##{container_id}")
        .append("svg:svg").attr("width", w + 1*chart_margin).attr("height", h + 1*chart_margin)
        # .attr("pointer-events", "all").append('svg:g').call(d3.behavior.zoom().on("zoom", redraw))
        .append("svg:g").attr("transform", translate(chart_margin,0))
    svg.append("svg:rect").attr("width", w).attr("height", h)
    svg.append("svg:clipPath")
        .attr("id", "clip_#{container_id}")
        .append("svg:rect")
        .attr("x", x(0))
        .attr("y", y(1))
        .attr("width", x(1) - x(0))
        .attr "height", y(0) - y(1)
    

    axis_options=xAxis.tickSubdivide(0)
    if use_week_ticks
        axis_options=axis_options.ticks(d3.time.weeks, 1)
    svg.append("svg:g").attr("class", "x grid")
        .attr("transform", translate(0, h)).call(axis_options.tickSize(-h))
    svg.append("svg:g").attr("class", "x axis")
        .attr("transform", translate(0,h)).call(axis_options.tickSize(6))
    svg.append("svg:g").attr("class", "y grid")
        .attr("transform", translate(0,0)).call(yAxis.tickSubdivide(0).tickSize(-screen_width+1*chart_margin).ticks(number_levels))
    svg.append("svg:g").attr("class", "y axis")
        .call(yAxis.tickSubdivide(0).tickSize(6).ticks(number_levels))

    

    svg.selectAll('budge_start')
      .data(budges_info)
      .enter().append('svg:path')
        .attr('class','budge_start')
        .attr("transform", (d)->translate(x(parse_date(d.start_date)),y(d.level_number-0.2)))
        .attr("d", d3.svg.symbol().type('triangle-up'))
        .attr('title', (d) -> "started level: #{d.level_number} <br/>on #{d.start_date}" )
        .attr('fill','rgba(0,255,0,0.5)')
        .on('click',(d)->highlight_level(d.id))
    
    #console.log(budges_info)
    svg.selectAll('budge_end')
      .data(budges_info)
      .enter().append('svg:path')
      # .enter().append('svg:circle')
        .attr('class','budge_end')
        .attr("transform", (d)->translate(x(parse_date(d.end_date_display)),y(d.level_number+0.2)))
        .attr("d", d3.svg.symbol().type('triangle-down'))
        # .attr("cx", (d) -> x(parse_time(d.end_time)))
        # .attr("cy", (d) -> y(d.level_number+0.2))
        # .attr("r", dot_radius_checkin)
        # .attr('title', (d) -> "finished level: #{d.level_number}<br/>at end of #{d.end_date}" )       
        .attr('title', (d) -> "finished level: #{d.level_number}<br/>at end of #{d.end_date}" )       
        .attr('fill','rgba(255,0,0,0.5)')
        .on('click',(d)->highlight_level(d.id))

    svg.selectAll("message")
        .data(player_messages_info)
        .enter().append("svg:circle")
            .attr("class", "message")
            .attr("cx", (d) -> x(parse_time((d.deliver_at))))
            .attr("cy", (d) -> y(d.level_number))
            .attr("r", dot_radius_msg)
            .on('mouseover', -> d3.select(this).attr('r', 2*dot_radius_msg))
            .on('mouseout',  -> d3.select(this).attr('r', dot_radius_msg))
            .attr('title', (d) -> "message:<br/>time: #{show_time(parse_time(d.deliver_at))}<br/>content: #{d.content}" )       
            .attr('fill','darkgray')
            .on('click',(d)->highlight_row(d.id,d.level_id,'message'))

    svg.selectAll("checkin")
        .data(checkins_info)
        .enter().append("svg:circle")
        # .enter().append("svg:path")
            .attr("class", "checkin")
            .attr("cx", (d) -> x(parse_time((d.created_at))))
            .attr("cy", (d) -> y(d.level_number+0.1))
            .attr("r", dot_radius_checkin)
            .on('mouseover', -> d3.select(this).attr('r', 2*dot_radius_checkin))
            .on('mouseout',  -> d3.select(this).attr('r', dot_radius_checkin))
            .attr('title', (d) -> "checkin:<br/>time: #{show_time(parse_time(d.created_at))}<br/>amount: #{d.amount_decimal}" )       
            .attr('fill','rgba(70, 130, 180,0.5)')
            .on('click',(d)->highlight_row(d.id,d.level_id,'checkin'))
            # .attr("transform", (d)->translate( (x(parse_time((d.created_at)))),y(d.level_number)))
            # .attr("d", d3.svg.symbol().type('cross').size(checkin_size))
            # .attr('path','rgba(255,255,255,0.8)')



            
window.make_player_timeline=make_player_timeline #make this a global function