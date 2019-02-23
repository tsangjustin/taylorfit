require "./index.styl"

ko.components.register "tf-data-partition",
  template: do require "./index.pug"
  viewModel: ( params ) ->
    unless ko.isObservable params.show_partition
      throw new TypeError "components/data_partition:
      expects [show_partition] to be observable"
    unless ko.isObservable params.model
      throw new TypeError "components/data_partition:
      expects [model] to be observable"

    model = params.model
    @show_partition = params.show_partition
    # Partition amount
    @fit_p = ko.observable 100
    @cross_p = ko.observable 0
    @validate_p = ko.observable 0
    # Partition rows
    @fit_row_start = ko.observable 0
    @fit_row_end = ko.observable 0
    @cross_row_start = ko.observable undefined
    @cross_row_end = ko.observable undefined
    @validate_row_start = ko.observable undefined
    @validate_row_end = ko.observable undefined
    # Errors
    @error_msg = ko.observable undefined
    @fit_invalid = ko.observable false
    @cross_invalid = ko.observable false
    @validate_invalid = ko.observable false

    check_split_valid = ( num ) ->
      num != undefined &&
      num != null &&
      num >= 0 &&
      num <= 100 &&
      !isNaN(num)

    @change_fit_partition = ( ) ->
      fit_partition = Number(@fit_p())
      cross_partition = Number(@cross_p())
      validate_partition = Number(@validate_p())
      is_fit_invalid = !check_split_valid(fit_partition)
      @fit_invalid(is_fit_invalid)
      sum_partition = fit_partition + cross_partition + validate_partition
      is_invalid_partition = is_fit_invalid ||
        @cross_invalid() ||
        @validate_invalid() ||
        sum_partition < 0 ||
        sum_partition > 100
      if is_invalid_partition
        @error_msg("Invalid fit partition percentage")
      else
        data_rows = model().rows.length
        partition_percentage = fit_partition / 100
        num_rows = Math.round(data_rows * partition_percentage)
        start_row = @fit_row_start()
        end_row = if data_rows <= start_row + num_rows then data_rows else start_row + num_rows
        @fit_row_end(end_row)
        @error_msg(undefined)

    @change_cross_partition = ( ) ->
      # Get partition values
      fit_partition = Number(@fit_p())
      cross_partition = Number(@cross_p())
      validate_partition = Number(@validate_p())
      #check if cross partition is valid number value
      cross_split_invalid = !check_split_valid(cross_partition)
      @cross_invalid(cross_split_invalid)
      # Get sum of partition values
      sum_partition = fit_partition + cross_partition + validate_partition
      is_invalid_partition = @fit_invalid() ||
        cross_split_invalid||
        @validate_invalid() ||
        sum_partition < 0 ||
        sum_partition > 100
      if is_invalid_partition
        @error_msg("Invalid cross partition percentage")
      else
        data_rows = model().rows.length
        partition_percentage = cross_partition / 100
        num_rows = Math.round(data_rows * partition_percentage)
        init_cross_start_row = @cross_row_start()
        start_row = if init_cross_start_row
        then init_cross_start_row
        else if @fit_row_end() && @fit_row_end() < data_rows
        then @fit_row_end() + 1
        else data_rows
        if init_cross_start_row == undefined
          @cross_row_start(start_row)
        end_row = if data_rows <= start_row + num_rows then data_rows else start_row + num_rows
        @cross_row_end(end_row)
        @error_msg(undefined)
    
    @change_validate_partition = ( ) ->
      fit_partition = Number(@fit_p())
      cross_partition = Number(@cross_p())
      validate_partition = Number(@validate_p())
      validate_split_invalid = !check_split_valid(validate_partition)
      @validate_invalid(validate_split_invalid)
      sum_partition = fit_partition + cross_partition + validate_partition
      is_invalid_partition = @fit_invalid() ||
        @cross_invalid() ||
        validate_split_invalid ||
        sum_partition < 0 ||
        sum_partition > 100
      if is_invalid_partition
        @error_msg("Invalid validate partition percentage")
      else
        data_rows = model().rows.length
        partition_percentage = validate_partition / 100
        num_rows = Math.round(data_rows * partition_percentage)
        init_start_row = @validate_row_start()
        start_row = if init_start_row
        then init_start_row
        else if @cross_row_end()
        then @cross_row_end() + 1
        else if @fit_row_end()
        then @fit_row_end() + 1
        else 1
        if init_start_row == undefined
          @validate_row_start(start_row)
        end_row = if data_rows <= start_row + num_rows then data_rows else start_row + num_rows
        @validate_row_end(end_row)
        @error_msg(undefined)
    
    '''
    Function handles data input change for row start of the fit partition
    '''
    @change_fit_start_row = ( ) ->
      fit_row_start = Number(@fit_row_start())
      fit_row_end = Number(@fit_row_end())
      data_rows = model().rows.length
      if fit_row_start == undefined
        @error_msg("Fit start row is not defined")
      else if fit_row_start < 1
        @error_msg("Fit start row has to be at least 1")
      else if fit_row_start > data_rows
        @error_msg("Fit start row has to be less than or equal to", data_rows)
      else if fit_row_start > fit_row_end
        @error_msg("Fit start row has to be less than the fit end row")
      else
        partition_percentage = Math.round((fit_row_end - fit_row_start + 1) / data_rows * 100)
        @fit_p(partition_percentage)
        @error_msg(undefined)
    
    @change_fit_end_row = ( ) ->
      fit_row_start = Number(@fit_row_start())
      fit_row_end = Number(@fit_row_end())
      data_rows = model().rows.length
      if fit_row_end == undefined
        @error_msg("Fit end row is not defined")
      else if fit_row_end < 1
        @error_msg("Fit end row has to be at least 1")
      else if fit_row_end > data_rows
        @error_msg("Fit end row has to be less than or equal to", data_rows)
      else if fit_row_start > fit_row_end
        @error_msg("Fit end row has to be less than the fit end row")
      else
        partition_percentage = Math.round((fit_row_end - fit_row_start + 1) / data_rows * 100)
        @fit_p(partition_percentage)
        @error_msg(undefined)
    
    @change_cross_start_row = ( ) ->
      cross_row_start = Number(@cross_row_start())
      cross_row_end = Number(@cross_row_end())
      data_rows = model().rows.length
      if cross_row_start == undefined
        @error_msg("Cross start row is not defined")
      else if cross_row_start < 1
        @error_msg("Cross start row has to be at least 1")
      else if cross_row_start > data_rows
        @error_msg("Cross start row has to be less than or equal to", data_rows)
      else if cross_row_start > cross_row_end
        @error_msg("Cross start row has to be less than the cross end row")
      else
        partition_percentage = Math.round((cross_row_end - cross_row_start + 1) / data_rows * 100)
        @cross_p(partition_percentage)
        @error_msg(undefined)

    @change_cross_end_row = ( ) ->
      cross_row_start = Number(@cross_row_start())
      cross_row_end = Number(@cross_row_end())
      data_rows = model().rows.length
      if cross_row_end == undefined
        @error_msg("Cross end row is not defined")
      else if cross_row_end < 1
        @error_msg("Cross end row has to be at least 1")
      else if cross_row_end > data_rows
        @error_msg("Cross end row has to be less than or equal to", data_rows)
      else if cross_row_start > cross_row_end
        @error_msg("Cross end row has to be less than the cross end row")
      else
        partition_percentage = Math.round((cross_row_end - cross_row_start + 1) / data_rows * 100)
        @cross_p(partition_percentage)
        @error_msg(undefined)
    
    @import_dataset = ( ) ->


    # Check if data partition popup should render
    @active = ko.computed ( ) =>
      @show_partition() != undefined && @show_partition() != false

    model.subscribe ( nextModel ) =>
      if nextModel != undefined
        @fit_row_start(1)
        if nextModel.rows != undefined
          @fit_row_end(nextModel.rows.length)

    return this