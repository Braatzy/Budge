translate = (x, y) -> "translate(" + x + "," + y + ")"

chart_margin=28
dot_radius=2

parse_time = d3.time.format("%Y-%m-%d %H:%M").parse
show_time = d3.time.format("%Y-%m-%d")

make_weight_chart = (weights,true_weight_lines,screen_width,screen_height,range_time,range_weight) ->
    weights=weights.map((t_w)->
        t: parse_time(t_w[0]),
        w:+t_w[1]  )

    true_weight_lines = true_weight_lines
        .map( (L) ->
            L.map((t_w) ->
                t: parse_time(t_w[0]),
                w:+t_w[1] )
            )

    w = screen_width - 1*chart_margin
    h = screen_height - 1*chart_margin

    x = d3.time.scale().range([ 0, w ])
    y = d3.scale.linear().range([ h, 0 ])
    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")
    svg = d3.select("#chart")
        .append("svg:svg")
        .attr("width", w + 1*chart_margin)
        .attr("height", h + 1*chart_margin)
        .append("svg:g")
        .attr("transform", translate(chart_margin,0))
    svg.append("svg:rect").attr("width", w).attr("height", h)
    svg.append("svg:clipPath")
        .attr("id", "clip")
        .append("svg:rect")
        .attr("x", x(0))
        .attr("y", y(1))
        .attr("width", x(1) - x(0))
        .attr "height", y(0) - y(1)
    smoothed_line = d3.svg.line()
        .x((d) ->  x(d.t))
        .y((d) ->  y(d.w) )
        .interpolate("basis")




    dom_all ={x: range_time.map((t)->parse_time(t)), y: range_weight.map((w)-> +w)}
    x.domain(dom_all.x)
    y.domain(dom_all.y)
    svg.append("svg:g").attr("class", "x grid").attr("transform", translate(0, h)).call(xAxis.tickSubdivide(0).tickSize(-h).ticks(d3.time.weeks, 1))
    svg.append("svg:g").attr("class", "y grid").attr("transform", translate(0,0)).call(yAxis.tickSubdivide(1).tickSize(-screen_width+1*chart_margin))
    svg.append("svg:g").attr("class", "x axis").attr("transform", translate(0,h)).call(xAxis.tickSubdivide(0).tickSize(6).ticks(d3.time.weeks, 1))
        # .selectAll("text").attr("x", 5).attr("dy", null).attr("text-anchor", null) #extend labels from right of ticks 
    svg.append("svg:g").attr("class", "y axis").call(yAxis.tickSubdivide(0).tickSize(6))
    svg.selectAll("dot")
        .data(weights)
        .enter().append("svg:circle")
            .attr("class", "dot")
            .attr("cx", (d) -> x(d.t))
            .attr("cy", (d) -> y(d.w))
            .attr("r", dot_radius)
            .on('mouseover', -> d3.select(this).attr('r', 2*dot_radius))
            .on('mouseout',  -> d3.select(this).attr('r', dot_radius))
    #         .append('svg:title').text((d) -> "#{format(d.x)}: #{d.y}lbs#{if d.c!=null then ('<br/>'+d.c) else ''}" )       
            .attr "clip-path", "url(#clip)"
        
    svg.selectAll("weight.smoothed")
        .data(true_weight_lines)
        .enter().append("svg:path")
            .attr("class", "weight smoothed")
            .attr("fill", "none")
            .attr("d", (d,i)->smoothed_line(true_weight_lines[i]))
            .attr("clip-path", "url(#clip)")

window.make_weight_chart=make_weight_chart #make this a global function