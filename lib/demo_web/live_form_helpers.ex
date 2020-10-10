defmodule LiveFormField do
  defstruct [:id, :value, :errors, :name, :label]
end

defmodule LiveFormHelpers do
  @moduledoc ~S"""
  TODO
  """

  alias Phoenix.HTML.Form
  import Phoenix.HTML
  import Phoenix.HTML.Tag

  @doc """
  TODO
  """
  def live_form_for(changeset, opts \\ []) do
    fields = Keyword.fetch!(opts, :fields)
    form = Phoenix.HTML.Form.form_for(changeset, "#")

    for field <- fields, into: %{} do
      {field,
       %LiveFormField{
         errors: List.wrap(Keyword.get(form.errors, field, [])),
         value: Form.input_value(form, field),
         label: Form.label(form, field),
         id: Form.input_id(form, field),
         name: Form.input_name(form, field)
       }}
    end
  end

  ## Form helpers

  @doc """
  Generates a text input.

  The form should either be a `Phoenix.HTML.Form` emitted
  by `form_for` or an atom.

  All given options are forwarded to the underlying input,
  default values are provided for id, name and value if
  possible.

  ## Examples

      # Assuming form contains a User schema
      text_input(f.name)
      #=> <input id="user_name" name="user[name]" type="text" value="">

      text_input(:user, :name)
      #=> <input id="user_name" name="user[name]" type="text" value="">

  """
  def text_input(field, opts \\ []) do
    generic_input(:text, field, opts)
  end

  @doc """
  Generates a hidden input.

  See `text_input/2` for example and docs.
  """
  def hidden_input(field, opts \\ []) do
    generic_input(:hidden, field, opts)
  end

  @doc """
  Generates an email input.

  See `text_input/2` for example and docs.
  """
  def email_input(field, opts \\ []) do
    generic_input(:email, field, opts)
  end

  @doc """
  Generates a number input.

  See `text_input/2` for example and docs.
  """
  def number_input(field, opts \\ []) do
    generic_input(:number, field, opts)
  end

  @doc """
  Generates a password input.

  For security reasons, the form data and parameter values
  are never re-used in `password_input/2`. Pass the value
  explicitly if you would like to set one.

  See `text_input/2` for example and docs.
  """
  def password_input(field, opts \\ [])
  def password_input(%LiveFormField{} = field, opts) do
    opts =
      opts
      |> Keyword.put_new(:type, "password")
      |> Keyword.put_new(:id, field.id)
      |> Keyword.put_new(:name, field.name)

    tag(:input, opts)
  end

  @doc """
  Generates an url input.

  See `text_input/2` for example and docs.
  """
  def url_input(field, opts \\ []) do
    generic_input(:url, field, opts)
  end

  @doc """
  Generates a search input.

  See `text_input/2` for example and docs.
  """
  def search_input(field, opts \\ []) do
    generic_input(:search, field, opts)
  end

  @doc """
  Generates a telephone input.

  See `text_input/2` for example and docs.
  """
  def telephone_input(field, opts \\ []) do
    generic_input(:tel, field, opts)
  end

  @doc """
  Generates a color input.

  Warning: this feature isn't available in all browsers.
  Check `http://caniuse.com/#feat=input-color` for further informations.

  See `text_input/2` for example and docs.
  """
  def color_input(field, opts \\ []) do
    generic_input(:color, field, opts)
  end

  @doc """
  Generates a range input.

  See `text_input/2` for example and docs.
  """
  def range_input(field, opts \\ []) do
    generic_input(:range, field, opts)
  end

  @doc """
  Generates a date input.

  Warning: this feature isn't available in all browsers.
  Check `http://caniuse.com/#feat=input-datetime` for further informations.

  See `text_input/2` for example and docs.
  """
  def date_input(field, opts \\ []) do
    generic_input(:date, field, opts)
  end

  @doc """
  Generates a datetime-local input.

  Warning: this feature isn't available in all browsers.
  Check `http://caniuse.com/#feat=input-datetime` for further informations.

  See `text_input/2` for example and docs.
  """
  def datetime_local_input(%LiveFormField{} = field, opts \\ []) do
    value = Keyword.get(opts, :value, field.value)
    opts = Keyword.put(opts, :value, datetime_local_input_value(value))

    generic_input(:"datetime-local", field, opts)
  end

  defp datetime_local_input_value(%NaiveDateTime{} = value) do
    <<date::10-binary, ?\s, hour_minute::5-binary, _rest::binary>> =
      NaiveDateTime.to_string(value)

    [date, ?T, hour_minute]
  end

  defp datetime_local_input_value(other), do: other

  @doc """
  Generates a time input.

  Warning: this feature isn't available in all browsers.
  Check `http://caniuse.com/#feat=input-datetime` for further informations.

  ## Options

    * `:precision` - Allowed values: `:minute`, `:second`, `:millisecond`.
      Defaults to `:minute`.

  All other options are forwarded. See `text_input/3` for example and docs.

  ## Examples

      time_input f.time
      #=> <input id="form_time" name="form[time]" type="time" value="23:00">

      time_input f.time, precision: :second
      #=> <input id="form_time" name="form[time]" type="time" value="23:00:00">

      time_input f.time, precision: :millisecond
      #=> <input id="form_time" name="form[time]" type="time" value="23:00:00.000">
  """
  def time_input(%LiveFormField{} = field, opts \\ []) do
    {precision, opts} = Keyword.pop(opts, :precision, :minute)
    value = opts[:value] || field.value
    opts = Keyword.put(opts, :value, truncate_time(value, precision))

    generic_input(:time, field, opts)
  end

  defp truncate_time(%Time{} = time, :minute) do
    time
    |> Time.to_string()
    |> String.slice(0, 5)
  end

  defp truncate_time(%Time{} = time, precision) do
    time
    |> Time.truncate(precision)
    |> Time.to_string()
  end

  defp truncate_time(value, _), do: value

  defp generic_input(type, field, opts) when is_list(opts) do
    opts =
      opts
      |> Keyword.put_new(:type, type)
      |> Keyword.put_new(:id, field.id)
      |> Keyword.put_new(:name, field.name)
      |> Keyword.put_new(:value, field.value)
      |> Keyword.update!(:value, &maybe_html_escape/1)

    tag(:input, opts)
  end

  defp maybe_html_escape(nil), do: nil
  defp maybe_html_escape(value), do: html_escape(value)

  @doc """
  Generates a textarea input.

  All given options are forwarded to the underlying input,
  default values are provided for id, name and textarea
  content if possible.

  ## Examples

      # Assuming form contains a User schema
      textarea(f.description)
      #=> <textarea id="user_description" name="user[description]"></textarea>

  ## New lines

  Notice the generated textarea includes a new line after
  the opening tag. This is because the HTML spec says new
  lines after tags must be ignored and all major browser
  implementations do that.

  So in order to avoid new lines provided by the user
  from being ignored when the form is resubmitted, we
  automatically add a new line before the text area
  value.
  """
  def textarea(%LiveFormField{} = field, opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:id, field.value)
      |> Keyword.put_new(:name, field.name)

    {value, opts} = Keyword.pop(opts, :value, field.value)
    content_tag(:textarea, ["\n", html_escape(value || "")], opts)
  end

  @doc """
  Generates a file input.
  See `text_input/2` for example and docs.
  """
  def file_input(%LiveFormField{} = field, opts \\ []) do

    opts =
      opts
      |> Keyword.put_new(:type, :file)
      |> Keyword.put_new(:id, field.value)
      |> Keyword.put_new(:name, field.name)

    opts =
      if opts[:multiple] do
        Keyword.update!(opts, :name, &"#{&1}[]")
      else
        opts
      end

    tag(:input, opts)
  end

  @doc """
  Generates a submit button to send the form.

  ## Examples

      submit do: "Submit"
      #=> <button type="submit">Submit</button>

  """
  def submit([do: _] = block_option), do: submit([], block_option)

  @doc """
  Generates a submit button to send the form.

  All options are forwarded to the underlying button tag.
  When called with a `do:` block, the button tag options
  come first.

  ## Examples

      submit "Submit"
      #=> <button type="submit">Submit</button>

      submit "Submit", class: "btn"
      #=> <button class="btn" type="submit">Submit</button>

      submit [class: "btn"], do: "Submit"
      #=> <button class="btn" type="submit">Submit</button>

  """
  def submit(value, opts \\ [])

  def submit(opts, [do: _] = block_option) do
    opts = Keyword.put_new(opts, :type, "submit")

    content_tag(:button, opts, block_option)
  end

  def submit(value, opts) do
    opts = Keyword.put_new(opts, :type, "submit")

    content_tag(:button, value, opts)
  end

  @doc """
  Generates a reset input to reset all the form fields to
  their original state.

  All options are forwarded to the underlying input tag.

  ## Examples

      reset "Reset"
      #=> <input type="reset" value="Reset">

      reset "Reset", class: "btn"
      #=> <input type="reset" value="Reset" class="btn">

  """
  def reset(value, opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:type, "reset")
      |> Keyword.put_new(:value, value)

    tag(:input, opts)
  end

  @doc """
  Generates a radio button.

  Invoke this function for each possible value you want
  to be sent to the server.

  ## Examples

      # Assuming form contains a User schema
      radio_button(f.role, "admin")
      #=> <input id="user_role_admin" name="user[role]" type="radio" value="admin">

  ## Options

  All options are simply forwarded to the underlying HTML tag.
  """
  def radio_button(%LiveFormField{} = field, value, opts \\ []) do
    escaped_value = html_escape(value)

    opts =
      opts
      |> Keyword.put_new(:type, "radio")
      |> Keyword.put_new(:id, field.id)
      |> Keyword.put_new(:name, field.name)

    opts =
      if escaped_value == html_escape(field.value) do
        Keyword.put_new(opts, :checked, true)
      else
        opts
      end

    tag(:input, [value: escaped_value] ++ opts)
  end

  @doc """
  Generates a checkbox.

  This function is useful for sending boolean values to the server.

  ## Examples

      # Assuming form contains a User schema
      checkbox(f.famous)
      #=> <input name="user[famous]" type="hidden" value="false">
          <input checked="checked" id="user_famous" name="user[famous]" type="checkbox" value="true">

  ## Options

    * `:checked_value` - the value to be sent when the checkbox is checked.
      Defaults to "true"

    * `:hidden_input` - controls if this function will generate a hidden input
      to submit the unchecked value or not. Defaults to "true"

    * `:unchecked_value` - the value to be sent when the checkbox is unchecked,
      Defaults to "false"

    * `:value` - the value used to check if a checkbox is checked or unchecked.
      The default value is extracted from the form data if available

  All other options are forwarded to the underlying HTML tag.

  ## Hidden fields

  Because an unchecked checkbox is not sent to the server, Phoenix
  automatically generates a hidden field with the unchecked_value
  *before* the checkbox field to ensure the `unchecked_value` is sent
  when the checkbox is not marked. Set `hidden_input` to false If you
  don't want to send values from unchecked checkbox to the server.
  """
  def checkbox(field, opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:type, "checkbox")
      |> Keyword.put_new(:id, field.id)
      |> Keyword.put_new(:name, field.name)

    {value, opts} = Keyword.pop(opts, :value, field.value)
    {checked_value, opts} = Keyword.pop(opts, :checked_value, true)
    {unchecked_value, opts} = Keyword.pop(opts, :unchecked_value, false)
    {hidden_input, opts} = Keyword.pop(opts, :hidden_input, true)

    # We html escape all values to be sure we are comparing
    # apples to apples. After all we may have true in the data
    # but "true" in the params and both need to match.
    value = html_escape(value)
    checked_value = html_escape(checked_value)
    unchecked_value = html_escape(unchecked_value)

    opts =
      if value == checked_value do
        Keyword.put_new(opts, :checked, true)
      else
        opts
      end

    if hidden_input do
      hidden_opts = [type: "hidden", value: unchecked_value]

      html_escape([
        tag(:input, hidden_opts ++ Keyword.take(opts, [:name, :disabled])),
        tag(:input, [value: checked_value] ++ opts)
      ])
    else
      html_escape([
        tag(:input, [value: checked_value] ++ opts)
      ])
    end
  end

  @doc """
  Generates a select tag with the given `options`.

  `options` are expected to be an enumerable which will be used to
  generate each respective `option`. The enumerable may have:

    * keyword lists - each keyword list is expected to have the keys
      `:key` and `:value`. Additional keys such as `:disabled` may
      be given to customize the option

    * two-item tuples - where the first element is an atom, string or
      integer to be used as the option label and the second element is
      an atom, string or integer to be used as the option value

    * atom, string or integer - which will be used as both label and value
      for the generated select

  ## Optgroups

  If `options` is map or keyword list where the first element is a string,
  atom or integer and the second element is a list or a map, it is assumed
  the key will be wrapped in an `<optgroup>` and the value will be used to
  generate `<options>` nested under the group.

  ## Examples

      # Assuming form contains a User schema
      select(form, :age, 0..120)
      #=> <select id="user_age" name="user[age]">
          <option value="0">0</option>
          ...
          <option value="120">120</option>
          </select>

      select(f.role, ["Admin": "admin", "User": "user"])
      #=> <select id="user_role" name="user[role]">
          <option value="admin">Admin</option>
          <option value="user">User</option>
          </select>

      select(f.role, [[key: "Admin", value: "admin", disabled: true],
                           [key: "User", value: "user"]])
      #=> <select id="user_role" name="user[role]">
          <option value="admin" disabled="disabled">Admin</option>
          <option value="user">User</option>
          </select>

      select(f.role, ["Admin": "admin", "User": "user"], prompt: "Choose your role")
      #=> <select id="user_role" name="user[role]">
          <option value="">Choose your role</option>
          <option value="admin">Admin</option>
          <option value="user">User</option>
          </select>

  If you want to select an option that comes from the database,
  such as a manager for a given project, you may write:

      select(f.manager_id, Enum.map(@managers, &{&1.name, &1.id}))
      #=> <select id="manager_id" name="project[manager_id]">
          <option value="1">Mary Jane</option>
          <option value="2">John Doe</option>
          </select>

  Finally, if the values are a list or a map, we use the keys for
  grouping:

      select(f.country, ["Europe": ["UK", "Sweden", "France"]], ...)
      #=> <select id="user_country" name="user[country]">
          <optgroup label="Europe">
            <option>UK</option>
            <option>Sweden</option>
            <option>France</option>
          </optgroup>
          ...
          </select>

  ## Options

    * `:prompt` - an option to include at the top of the options with
      the given prompt text

    * `:selected` - the default value to use when none was sent as parameter

  Be aware that a `:multiple` option will not generate a correctly
  functioning multiple select element. Use `multiple_select/4` instead.

  All other options are forwarded to the underlying HTML tag.
  """
  def select(%LiveFormField{} = field, options, opts \\ []) do
    {selected, opts} = selected(field, opts)
    options_html = Form.options_for_select(options, selected)

    {options_html, opts} =
      case Keyword.pop(opts, :prompt) do
        {nil, opts} -> {options_html, opts}
        {prompt, opts} -> {[content_tag(:option, prompt, value: "") | options_html], opts}
      end

    opts =
      opts
      |> Keyword.put_new(:id, field.id)
      |> Keyword.put_new(:name, field.name)

    content_tag(:select, options_html, opts)
  end

  @doc """
  Returns options to be used inside a select.

  This is useful when building the select by hand.
  It expects all options and one or more select values.

  ## Examples

      options_for_select(["Admin": "admin", "User": "user"], "admin")
      #=> <option value="admin" selected="selected">Admin</option>
          <option value="user">User</option>

  Groups are also supported:

      options_for_select(["Europe": ["UK", "Sweden", "France"], ...], nil)
      #=> <optgroup label="Europe">
            <option>UK</option>
            <option>Sweden</option>
            <option>France</option>
          </optgroup>

  """
  def options_for_select(options, selected_values) do
    {:safe,
     escaped_options_for_select(
       options,
       selected_values |> List.wrap() |> Enum.map(&html_escape/1)
     )}
  end

  defp escaped_options_for_select(options, selected_values) do
    Enum.reduce(options, [], fn
      {option_key, option_value}, acc ->
        [acc | option(option_key, option_value, [], selected_values)]

      options, acc when is_list(options) ->
        {option_key, options} = Keyword.pop(options, :key)

        option_key ||
          raise ArgumentError,
                "expected :key key when building <option> from keyword list: #{inspect(options)}"

        {option_value, options} = Keyword.pop(options, :value)

        option_value ||
          raise ArgumentError,
                "expected :value key when building <option> from keyword list: #{inspect(options)}"

        [acc | option(option_key, option_value, options, selected_values)]

      option, acc ->
        [acc | option(option, option, [], selected_values)]
    end)
  end

  defp selected(field, opts) do
    {value, opts} = Keyword.pop(opts, :value)
    {selected, opts} = Keyword.pop(opts, :selected)

    if value != nil do
      {value, opts}
    else
      param = field_to_string(field.name)
      {selected || field.value, opts}
    end
  end

  defp option(group_label, group_values, [], value)
       when is_list(group_values) or is_map(group_values) do
    section_options = escaped_options_for_select(group_values, value)
    {:safe, contents} = content_tag(:optgroup, {:safe, section_options}, label: group_label)
    contents
  end

  defp option(option_key, option_value, extra, value) do
    option_key = html_escape(option_key)
    option_value = html_escape(option_value)
    opts = [value: option_value, selected: option_value in value] ++ extra
    {:safe, contents} = content_tag(:option, option_key, opts)
    contents
  end

  @doc """
  Generates a select tag with the given `options`.

  Values are expected to be an Enumerable containing two-item tuples
  (like maps and keyword lists) or any Enumerable where the element
  will be used both as key and value for the generated select.

  ## Examples

      # Assuming form contains a User schema
      multiple_select(form, :roles, ["Admin": 1, "Power User": 2])
      #=> <select id="user_roles" name="user[roles][]">
          <option value="1">Admin</option>
          <option value="2">Power User</option>
          </select>

      multiple_select(form, :roles, ["Admin": 1, "Power User": 2], selected: [1])
      #=> <select id="user_roles" name="user[roles][]">
          <option value="1" selected="selected">Admin</option>
          <option value="2">Power User</option>
          </select>

  When working with structs, associations and embeds, you will need to tell
  Phoenix how to extract the value out of the collection. For example,
  imagine `user.roles` is a list of `%Role{}` structs. You must call it as:

      multiple_select(form, :roles, ["Admin": 1, "Power User": 2],
                      selected: Enum.map(@user.roles, &(&1.id))

  The `:selected` option will mark the given IDs as selected unless the form
  is being resubmitted. When resubmitted, it uses the form params as values.

  ## Options

    * `:selected` - the default options to be marked as selected. The values
       on this list are ignored in case ids have been set as parameters.

  All other options are forwarded to the underlying HTML tag.
  """
  def multiple_select(%LiveFormField{} = field, options, opts \\ []) do
    {selected, opts} = selected(field, opts)

    opts =
      opts
      |> Keyword.put_new(:id, field.id)
      |> Keyword.put_new(:name, field.name <> "[]")
      |> Keyword.put_new(:multiple, "")

    content_tag(:select, options_for_select(options, selected), opts)
  end

  ## Datetime

  @doc ~S'''
  Generates select tags for datetime.

  ## Examples

      # Assuming form contains a User schema
      datetime_select f.born_at
      #=> <select id="user_born_at_year" name="user[born_at][year]">...</select> /
          <select id="user_born_at_month" name="user[born_at][month]">...</select> /
          <select id="user_born_at_day" name="user[born_at][day]">...</select> —
          <select id="user_born_at_hour" name="user[born_at][hour]">...</select> :
          <select id="user_born_at_min" name="user[born_at][minute]">...</select>

  If you want to include the seconds field (hidden by default), pass `second: []`:

      # Assuming form contains a User schema
      datetime_select form, :born_at, second: []

  If you want to configure the years range:

      # Assuming form contains a User schema
      datetime_select f.born_at, year: [options: 1900..2100]

  You are also able to configure `:month`, `:day`, `:hour`, `:minute` and
  `:second`. All options given to those keys will be forwarded to the
  underlying select. See `select/4` for more information.

  For example, if you are using Phoenix with Gettext and you want to localize
  the list of months, you can pass `:options` to the `:month` key:

      # Assuming form contains a User schema
      datetime_select f.born_at, month: [
        options: [
          {gettext("January"), "1"},
          {gettext("February"), "2"},
          {gettext("March"), "3"},
          {gettext("April"), "4"},
          {gettext("May"), "5"},
          {gettext("June"), "6"},
          {gettext("July"), "7"},
          {gettext("August"), "8"},
          {gettext("September"), "9"},
          {gettext("October"), "10"},
          {gettext("November"), "11"},
          {gettext("December"), "12"},
        ]
      ]

  You may even provide your own `localized_datetime_select/3` built on top of
  `datetime_select/2`:

      defp localized_datetime_select(field, opts \\ []) do
        opts =
          Keyword.put(opts, :month, options: [
            {gettext("January"), "1"},
            {gettext("February"), "2"},
            {gettext("March"), "3"},
            {gettext("April"), "4"},
            {gettext("May"), "5"},
            {gettext("June"), "6"},
            {gettext("July"), "7"},
            {gettext("August"), "8"},
            {gettext("September"), "9"},
            {gettext("October"), "10"},
            {gettext("November"), "11"},
            {gettext("December"), "12"},
          ])

        datetime_select(field, opts)
      end

  ## Options

    * `:value` - the value used to select a given option.
      The default value is extracted from the form data if available

    * `:default` - the default value to use when none was given in
      `:value` and none is available in the form data

    * `:year`, `:month`, `:day`, `:hour`, `:minute`, `:second` - options passed
      to the underlying select. See `select/4` for more information.
      The available values can be given in `:options`.

    * `:builder` - specify how the select can be build. It must be a function
      that receives a builder that should be invoked with the select name
      and a set of options. See builder below for more information.

  ## Builder

  The generated datetime_select can be customized at will by providing a
  builder option. Here is an example from EEx:

      <%= datetime_select f.born_at, builder: fn b -> %>
        Date: <%= b.(:day, []) %> / <%= b.(:month, []) %> / <%= b.(:year, []) %>
        Time: <%= b.(:hour, []) %> : <%= b.(:minute, []) %>
      <% end %>

  Although we have passed empty lists as options (they are required), you
  could pass any option there and it would be given to the underlying select
  input.

  In practice, we recommend you to create your own helper with your default
  builder:

      def my_datetime_select(field, opts \\ []) do
        builder = fn b ->
          ~e"""
          Date: <%= b.(:day, []) %> / <%= b.(:month, []) %> / <%= b.(:year, []) %>
          Time: <%= b.(:hour, []) %> : <%= b.(:minute, []) %>
          """
        end

        datetime_select(field, [builder: builder] ++ opts)
      end

  Then you are able to use your own datetime_select throughout your whole
  application.

  ## Supported date values

  The following values are supported as date:

    * a map containing the `year`, `month` and `day` keys (either as strings or atoms)
    * a tuple with three elements: `{year, month, day}`
    * a string in ISO 8601 format
    * `nil`

  ## Supported time values

  The following values are supported as time:

    * a map containing the `hour` and `minute` keys and an optional `second` key (either as strings or atoms)
    * a tuple with three elements: `{hour, min, sec}`
    * a tuple with four elements: `{hour, min, sec, usec}`
    * `nil`

  '''
  def datetime_select(%LiveFormField{} = field, opts \\ []) do
    value = Keyword.get(opts, :value, field.value || Keyword.get(opts, :default))

    builder =
      Keyword.get(opts, :builder) ||
        fn b ->
          date = date_builder(b, opts)
          time = time_builder(b, opts)
          html_escape([date, raw(" &mdash; "), time])
        end

    builder.(datetime_builder(field, date_value(value), time_value(value), opts))
  end

  @doc """
  Generates select tags for date.

  Check `datetime_select/2` for more information on options and supported values.
  """
  def date_select(%LiveFormField{} = field, opts \\ []) do
    value = Keyword.get(opts, :value, field.value || Keyword.get(opts, :default))
    builder = Keyword.get(opts, :builder) || (&date_builder(&1, opts))
    builder.(datetime_builder(field, date_value(value), nil, opts))
  end

  defp date_builder(b, _opts) do
    html_escape([b.(:year, []), raw(" / "), b.(:month, []), raw(" / "), b.(:day, [])])
  end

  defp date_value(%{"year" => year, "month" => month, "day" => day}),
    do: %{year: year, month: month, day: day}

  defp date_value(%{year: year, month: month, day: day}),
    do: %{year: year, month: month, day: day}

  defp date_value({{year, month, day}, _}), do: %{year: year, month: month, day: day}
  defp date_value({year, month, day}), do: %{year: year, month: month, day: day}

  defp date_value(nil), do: %{year: nil, month: nil, day: nil}

  defp date_value(string) when is_binary(string) do
    string
    |> Date.from_iso8601!()
    |> date_value
  end

  defp date_value(other), do: raise(ArgumentError, "unrecognized date #{inspect(other)}")

  @doc """
  Generates select tags for time.

  Check `datetime_select/2` for more information on options and supported values.
  """
  def time_select(%LiveFormField{} = field, opts \\ []) do
    value = Keyword.get(opts, :value, field.value || Keyword.get(opts, :default))
    builder = Keyword.get(opts, :builder) || (&time_builder(&1, opts))
    builder.(datetime_builder(field, nil, time_value(value), opts))
  end

  defp time_builder(b, opts) do
    time = html_escape([b.(:hour, []), raw(" : "), b.(:minute, [])])

    if Keyword.get(opts, :second) do
      html_escape([time, raw(" : "), b.(:second, [])])
    else
      time
    end
  end

  defp time_value(%{"hour" => hour, "minute" => min} = map),
    do: %{hour: hour, minute: min, second: Map.get(map, "second", 0)}

  defp time_value(%{hour: hour, minute: min} = map),
    do: %{hour: hour, minute: min, second: Map.get(map, :second, 0)}

  defp time_value({_, {hour, min, sec}}),
    do: %{hour: hour, minute: min, second: sec}

  defp time_value({hour, min, sec}),
    do: %{hour: hour, minute: min, second: sec}

  defp time_value(nil), do: %{hour: nil, minute: nil, second: nil}

  defp time_value(string) when is_binary(string) do
    string
    |> Time.from_iso8601!()
    |> time_value
  end

  defp time_value(other), do: raise(ArgumentError, "unrecognized time #{inspect(other)}")

  @months [
    {"January", "1"},
    {"February", "2"},
    {"March", "3"},
    {"April", "4"},
    {"May", "5"},
    {"June", "6"},
    {"July", "7"},
    {"August", "8"},
    {"September", "9"},
    {"October", "10"},
    {"November", "11"},
    {"December", "12"}
  ]

  map =
    &Enum.map(&1, fn i ->
      pre = if i < 10, do: "0"
      {"#{pre}#{i}", i}
    end)

  @days map.(1..31)
  @hours map.(0..23)
  @minsec map.(0..59)

  defp datetime_builder(field, date, time, parent) do
    id = Keyword.get(parent, :id, field.id)
    name = Keyword.get(parent, :name, field.name)

    fn
      :year, opts when date != nil ->
        {year, _, _} = :erlang.date()

        {value, opts} =
          datetime_options(:year, (year - 5)..(year + 5), id, name, parent, date, opts)

        Form.select(:datetime, :year, value, opts)

      :month, opts when date != nil ->
        {value, opts} = datetime_options(:month, @months, id, name, parent, date, opts)
        Form.select(:datetime, :month, value, opts)

      :day, opts when date != nil ->
        {value, opts} = datetime_options(:day, @days, id, name, parent, date, opts)
        Form.select(:datetime, :day, value, opts)

      :hour, opts when time != nil ->
        {value, opts} = datetime_options(:hour, @hours, id, name, parent, time, opts)
        Form.select(:datetime, :hour, value, opts)

      :minute, opts when time != nil ->
        {value, opts} = datetime_options(:minute, @minsec, id, name, parent, time, opts)
        Form.select(:datetime, :minute, value, opts)

      :second, opts when time != nil ->
        {value, opts} = datetime_options(:second, @minsec, id, name, parent, time, opts)
        Form.select(:datetime, :second, value, opts)
    end
  end

  defp datetime_options(type, values, id, name, parent, datetime, opts) do
    opts = Keyword.merge(Keyword.get(parent, type, []), opts)
    suff = Atom.to_string(type)

    {value, opts} = Keyword.pop(opts, :options, values)

    {value,
     opts
     |> Keyword.put_new(:id, id <> "_" <> suff)
     |> Keyword.put_new(:name, name <> "[" <> suff <> "]")
     |> Keyword.put_new(:value, Map.get(datetime, type))}
  end

  @doc """
  Generates a label tag.

  Useful when wrapping another input inside a label.

  ## Examples

      label do
        radio_button :user, :choice, "Choice"
      end
      #=> <label class="control-label">...</label>

      label class: "control-label" do
        radio_button :user, :choice, "Choice"
      end
      #=> <label class="control-label">...</label>

  """
  def label(do_block)

  def label(do: block) do
    content_tag(:label, block, [])
  end

  def label(opts, do: block) when is_list(opts) do
    content_tag(:label, block, opts)
  end

  @doc """
  Generates a label tag for the given field.

  The form should either be a `Phoenix.HTML.Form` emitted
  by `form_for` or an atom.

  All given options are forwarded to the underlying tag.
  A default value is provided for `for` attribute but can
  be overriden if you pass a value to the `for` option.
  Text content would be inferred from `field` if not specified.

  To wrap a label around an input, see `label/1`.

  ## Examples

      # Assuming form contains a User schema
      label(f.name, "Name")
      #=> <label for="user_name">Name</label>

      label(f.email, "Email")
      #=> <label for="user_email">Email</label>

      label(f.email)
      #=> <label for="user_email">Email</label>

      label(:user, :email, class: "control-label")
      #=> <label for="user_email" class="control-label">Email</label>

      label :user, :email do
        "E-mail Address"
      end
      #=> <label for="user_email">E-mail Address</label>

      label :user, :email, class: "control-label" do
        "E-mail Address"
      end
      #=> <label class="control-label" for="user_email">E-mail Address</label>

  """
  def label(%LiveFormField{} = field) do
    label(field, [])
  end

  @doc """
  See `label/1`.
  """
  def label(field, text_or_do_block_or_attributes)

  def label(field, do: block) do
    label(field, [], do: block)
  end

  def label(field, opts) when is_list(opts) do
    label(field, field.label, opts)
  end

  def label(field, text) do
    label(field, text, [])
  end

  @doc """
  See `label/1`.
  """
  def label(field, text, do_block_or_attributes)

  def label(%LiveFormField{} = field, opts, do: block) when is_list(opts) do
    opts = Keyword.put_new(opts, :for, field.id)
    content_tag(:label, block, opts)
  end

  def label(%LiveFormField{} = field, text, opts) when is_list(opts) do
    opts = Keyword.put_new(opts, :for, field.id)
    content_tag(:label, text, opts)
  end

  # Normalize field name to string version
  defp field_to_string(field) when is_atom(field), do: Atom.to_string(field)
  defp field_to_string(field) when is_binary(field), do: field
end
