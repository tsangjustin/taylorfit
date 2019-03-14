
require "./index.styl"

numberOrNull = ( n ) ->
  if isNaN n then null else n or 0

ko.components.register "tf-result",
  template: do require "./index.pug"
  viewModel: ( params ) ->
    unless ko.isObservable params.model
      throw new TypeError "components/result:
      expects [model] to be observable"

    model = params.model() # now static

    @result_fit = model.result_fit
    @result_cross = model.result_cross
    @result_validation = model.result_validation
    @data_fit = model.data_fit
    @data_cross = model.data_cross
    @data_validation = model.data_validation
    @extra_fit = model.extra_fit
    @extra_cross = model.extra_cross
    @extra_validation = model.extra_validation
    @dependent = model.dependent
    @psig = model.psig
    

    @graph_data = ko.computed ( ) =>
      fit = @extra_fit()
      cross = @extra_cross()
      validation = @extra_validation()

      max = Math.max (fit?.length or 0), (cross?.length or 0), (validation?.length or 0)

      data = [ ]
      for index in [0...max] by 1
        data[index] = d = [  ]
        if fit
          if f = fit[index]
            d.push numberOrNull f[1]
            d.push numberOrNull f[2]
          else
            d.push null
            d.push null
        if cross
          if c = cross[index]
            d.push numberOrNull c[1]
            d.push numberOrNull c[2]
          else
            d.push null
            d.push null
        if validation
          if v = validation[index]
            d.push numberOrNull v[1]
            d.push numberOrNull v[2]
          else
            d.push null
            d.push null
      return data

    @graph_row_labels = ko.computed ( ) =>
      fit = @extra_fit()
      cross = @extra_cross()
      validation = @extra_validation()

      counter = 0

      index = () =>
        return if (++counter == 1) then "" else counter
      
      labels = [ ]
      if fit
        labels.push "x" + index()
        labels.push "Fit Data"
      if cross
        labels.push "x" + index()
        labels.push "Cross Data"
      if validation
        labels.push "x" + index()
        labels.push "Validation Data"
      return labels
    

    
    e = document.getElementById("graphs")
    global.selectedvalue = e.options[e.selectedIndex].value
      
    
    return this
