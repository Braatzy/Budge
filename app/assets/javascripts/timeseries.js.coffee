translate = (x, y) -> "translate(" + x + "," + y + ")"
show_date = d3.time.format("%Y-%m-%d")
endsWith = (string, pattern) ->
  d = string.length - pattern.length
  d >= 0 and string.indexOf(pattern, d) is d

time_series_chart = ->
  xValue = (d) -> d[0]
  yValue = (d) -> d[1]
  y2_value = null
  chart = (selection) ->
    selection.each (data) -> 
      brush = ->
        xscale.domain (if brush.empty() then x_overview_scale.domain() else brush.extent())
        chart_body.select(".x.axis").call xAxis
        if style=='area'
          chart_body.select("path").attr "d", area
        if style=='bar'
          new_domain=brush.extent()
          n_bars=data.filter((d)-> new_domain[0]<=xValue(d) and xValue(d)<=new_domain[1]).length
          n_bars=data.length if n_bars==0
          update_bars(bars,n_bars)
        if style=='scatter'
          update_scatter(scatter)
        return

      xscale = d3.time.scale().range([ 0, width ])
      x_overview_scale = d3.time.scale().range([ 0, width ])
      yscale = d3.scale.linear().range([ height, 0 ])
      y_overview_scale = d3.scale.linear().range([ height_overview, 0 ])
      xAxis = d3.svg.axis().scale(xscale).orient("bottom")
      xAxis2 = d3.svg.axis().scale(x_overview_scale).orient("bottom")
      yAxis = d3.svg.axis().scale(yscale).orient("left")
    
      brush = d3.svg.brush().x(x_overview_scale).on("brush", brush)
      area = d3.svg.area().interpolate("monotone")
        .x((d) -> xscale(xValue(d)))
        .y0(height)
        .y1((d) -> yscale(yValue(d)))
      area2 = d3.svg.area()
        .x((d) ->x_overview_scale(xValue(d)))
        .y0(height_overview)
        .y1((d)->y_overview_scale yValue(d))
      draw_bars = (obj,n_bars) ->
        obj.append("rect").attr("class", "bar")
          .attr("x", (d)-> xscale(xValue(d)))
          .attr("y", (d)-> yscale(yValue(d)))
          .attr("width", (width_chart())/n_bars)
          .attr("height", (d)->  height-yscale(yValue(d)))
          .attr('fill', "steelblue")
          .on('mouseover', -> d3.select(this).attr('fill', "lightsteelblue"))
          .on('mouseout',  -> d3.select(this).attr('fill', "steelblue"))
          .attr("title",(d)->"#{show_date(xValue(d))} -- #{yaxis_label}: #{yValue(d)}")
          .attr("clip-path", "url(#clip)")
      update_bars = (obj,n_bars) ->
        obj.attr("x", (d)-> xscale(xValue(d))).attr("y", (d)-> yscale(yValue(d))).attr("width", (width-margin.left-margin.right)/n_bars)
      draw_stacked_bars = (data) -> 
        series=chart_body.selectAll("g.series").data(data).enter().append("svg:g")
          .attr("class","series")
          .style("fill",(d,i)->color_scale(i))
        series.selectAll("rect").data((s)->s).enter().append("rect").attr("class", "bar")
          .attr("x",(d)-> xscale(d.x))
          .attr("y",(d)-> y_bar_value(d))
          .attr("height",(d)-> height_bar_value(d))
          .attr("width",10)
          .attr("title",(d)->"#{show_date(xValue(d))} -- #{yaxis_label}: #{yValue(d)}")
          .attr("clip-path", "url(#clip)")
        reversed_index = (i) -> data.length-1-i
        legend=svg.append('g').attr('class','legend')
          .attr('transform',translate(width, height_chart()/4))
        legend_series=legend.selectAll('series').data(data.reverse()).enter().append('svg:g').attr('class','series')
        legend_series.append('rect').attr('class','bar')
          .attr('x',0)
          .attr('y',(d,i)->i*15)
          .attr('width',10)
          .attr('height',10)
          .style("fill",(d,i)->color_scale(reversed_index(i)))
        legend_series.append('text').attr('class','series_label')
          .attr('x',15).attr('y',(d,i)->8+i*15)
          .text((d,i)->"#{series_names[reversed_index(i)]}")
      draw_scatter= (obj,y_axis_value,color,ylabel)->
        ylabel_default=(d)->"#{show_date(xValue(d))} -- #{ylabel}: #{y_axis_value(d)}"
        obj.append("svg:circle")
          .attr("class", "dot")
          .attr("cx", (d) -> xscale(xValue(d)))
          .attr("cy", (d) -> yscale(y_axis_value(d)))
          .attr("r", dot_radius)
          .on('mouseover', -> d3.select(this).attr('r', 2*dot_radius))
          .on('mouseout',  -> d3.select(this).attr('r', dot_radius))
          .attr("title",(d) -> if $.isFunction(ylabel) then ylabel(d) else ylabel_default(d))
          .attr("fill",color)
          .attr "clip-path", "url(#clip)"
      
      update_scatter = (obj) -> obj.attr("cx", (d) -> xscale(xValue(d))).attr("cy", (d) -> yscale(yValue(d)))
        
      svg = d3.select(page_element).append("svg").data([data])
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + height_overview + margin.top*2 + margin.bottom*2)
      svg.append("defs")
        .append("clipPath").attr("id", "clip")
        .append("rect").attr("width", width_chart()).attr("height", height_chart())
      chart_body = svg.append("g").attr("class","chart_body").attr("transform", translate(margin.left,margin.top))
      
      if height_overview>0
        context = svg.append("g").attr("class","overview").attr("transform", translate(margin.left,height+margin.top))

      if style=='stacked bar'
        xdom=d3.extent(data[0], (d) -> xValue(d) )
        set_color_scale = (colors)->
          colors=(color for color in colors[0..series_names.length-1])
          return d3.scale.ordinal().range(colors)
        if series_names.length<=3 and series_colors.length==0
          color_scale=set_color_scale(['steelblue','lightsteelblue','lightblue'])
        else if series_names.length<=10 and series_colors.length==0 
          color_scale=d3.scale.category10()
        else
          color_scale=set_color_scale(series_colors)
                  
        ymax=d3.max(data, (series)->d3.max(series, (d)->d.y0+d.y))
        y_domain=[0,ymax] unless y_domain
        y_bar_value = (d) -> height_chart() - (d.y + d.y0) * height_chart() / ymax
        height_bar_value = (d) -> height_chart() - d.y0 * height_chart() / ymax - y_bar_value(d)
      else
        xdom=d3.extent(data, (d) -> xValue(d) )
        y_domain = [ 0, d3.max(data, (d) -> yValue(d))*1.1 ] unless y_domain

      xdom=xdom.map((date,index)->if index==0 then d3.time.day.offset(date,-1) else d3.time.day.offset(date,1)) #offset to include the first and last day
      xscale.domain(xdom).range([ 0, width_chart() ])
      yscale.domain(y_domain).range [ height_chart(), 0 ]
      x_overview_scale.domain(xscale.domain()).range(xscale.range())
      y_overview_scale.domain(yscale.domain())
      if style=='area'
        data_to_plot=chart_body.append("path").data([ data ]).attr("clip-path", "url(#clip)")
        data_to_plot.attr("class","area").attr("d", area)
      if style=='bar'
        bars=chart_body.selectAll("rect").data(data)
        draw_bars(bars.enter(),data.length)
      if style=='stacked bar'
        draw_stacked_bars(data)
          
        
      if style=='scatter'
        scatter=chart_body.selectAll("dot").data(data)
        draw_scatter(scatter.enter(),yValue,"grey",yseries_label)
        if y2_value
          scatter2=chart_body.selectAll("dot second").data(data)
          draw_scatter(scatter2.enter(),y2_value,"black",yseries2_label)
          
      xaxis=chart_body.append("g").attr("class", "x axis").attr("transform", translate(0,height_chart())).call(xAxis)
      xaxis.append("svg:text")
          .attr("y",5).attr("x",width-margin.left)
          .attr("class",'axis-label')
          .attr("text-anchor", "begin")
          .text("#{xaxis_label}")
      yaxis=chart_body.append("g").attr("class", "y axis").call yAxis
      yaxis.append("svg:text")
        .attr("y",-40).attr("x",-height/2+margin.bottom)
        .attr("transform","rotate(-90 0 0)")
        .attr("class",'y axis axis-label')
        .attr("text-anchor", "middle")
        .text("#{yaxis_label}")
      if height_overview>0
        context.append("path").attr("class","area").data([ data ]).attr "d", area2
        context.append("g").attr("class", "x axis").attr("transform", "translate(0," + height_overview + ")").call xAxis2
        context.append("g").attr("class", "x brush").call(brush).selectAll("rect").attr("y", -6).attr "height", height_overview + 7
      #Match all elements with a title tag qtip them    
      $('.bar[title], .dot[title]').qtip({position: { my: 'bottom center', at: 'top center' }} )
      
  page_element="#chart"
  margin =
    top: 10
    right: 25
    bottom: 20
    left: 50
  width = 960
  height = 500
  height_overview = 0
  xaxis_label=''
  yaxis_label=''
  yseries_label = yaxis_label
  yseries2_label = yaxis_label
  y_domain = null
  style='bar'
  series_names=[]
  series_colors=[]
  
  
  dot_radius=2
  width_chart= () -> width-margin.left-margin.right
  height_chart= () -> height-margin.top-margin.bottom
  
  
  chart.margin = (_) ->
    return margin  unless arguments.length
    margin = _
    return chart
  chart.width = (_) ->
    return width  unless arguments.length
    width = _
    return chart
  chart.height = (_) ->
    return height  unless arguments.length
    height = _
    return chart
  chart.height_overview = (_) ->
    return height_overview  unless arguments.length
    height_overview = _
    return chart
  chart.x = (_) ->
    return xValue  unless arguments.length
    xValue = _
    return chart
  chart.y = (_) ->
    return yValue  unless arguments.length
    yValue = _
    return chart
  chart.y2 = (_) ->
    return y2_value unless arguments.length
    y2_value= _
    return chart
  chart.page_element = (_) ->
    return page_element  unless arguments.length
    page_element = _
    return chart
  chart.xaxis_label = (_) ->
    return xaxis_label  unless arguments.length
    xaxis_label = _
    return chart
  chart.yaxis_label = (_) ->
    return yaxis_label  unless arguments.length
    yaxis_label = _
    return chart
  chart.yseries_label = (_) ->
    return yseries_label  unless arguments.length
    yseries_label = _
    return chart    
  chart.yseries2_label = (_) ->
    return yseries2_label  unless arguments.length
    yseries2_label = _
    return chart
  chart.style = (_) ->
    return style  unless arguments.length
    style = _
    return chart
  chart.plot = (data)->
    d3.select(page_element).datum(data).call(chart)
    return chart
  chart.plot_file = (data_file) -> 
    if endsWith(data_file,'.csv')
      d3.csv(data_file, chart.plot)
    else if endsWith(data_file,'.json')
      d3.json(data_file, chart.plot)
    return chart
  chart.y_domain = (_) ->
    return y_domain unless arguments.length
    y_domain= _
    return chart
  chart.series_names = (_) ->
    return series_names unless arguments.length
    series_names= _
    return chart    
  chart.series_colors = (_) ->
    return series_colors unless arguments.length
    series_colors= _
    return chart    
  
  return chart
  


window.time_series_chart=time_series_chart #make this a global function  