/// Exception message formatting helper types
typedef MsgVarDef = ({String n, Object? v});
typedef MsgVarList = List<MsgVarDef>;

/// Mixin to augment classes with a reference to another object. Used by
/// [Exception] subclasses to create a chain of references of exceptions that
/// can be search to determine a source of exceptions to simplify error handling
/// while still maintaining a history of the exception for logging and debugging
/// purposes.
///
/// Also adds a method to generate toString() for exceptions in a standard
/// format and adds the nested exceptions to the resulting string.
///
/// Example:
/// ```
///    class MyException with CausedBy extends Exception {
///      final String id;
///      final String ssn;
///      final String? reason;
///
///      Example(this.var1, this.var2, {this.reason, super.causedby});
///
///      @override
///      String toString() => exceptionMessage(
///        "MyException", // base
///        [ // vars - always displayed
///          (n: "id", v: id),
///          (n: "pii", v: (n) => myLogEncoder.encode(ssn)),
///        ],
///        [ // opts - only displayed if value is not null or empty
///          (n: "reason", v:reason),
///        ],
///      );
///    }
/// ```
/// `toString` will always output entries for `id` and `ssn` (as 'pii') but only
/// output a value for `reason` if one is been provided to the constructor.
///
/// A value can be set for `causeBy` to create a chain of objects providing a
/// history of exceptions, along with the values that caused them; something not
/// usually available from a stack trace.
///
/// When value has been set for `causedBy` it's `toString` will be added to the
/// end of the output.
///
/// The code to use this may look something like:
/// ```
///   try {
///     // Do something which might fail
///   }
///   catch (e) {
///     throw MyException(id: userId, ssn: userSocial, causedBy:e);
///   }
/// ```
/// and the output of `toString` may look something like:
/// ```
///    MyException: id=304523 pii=%$@%$@$^@#$% reason:"Fetching DOB"
///    causedBy: ConnectionException
/// ```
/// The chain of objects created by `causedBy` can be searched using the
/// `isCaused` method to bypass intermediate exceptions that are just there
/// to provide a history of the calling sequence along with the selected values.
///
/// Perhaps in this case we can use:
/// ```   final cause = exception.isCaused((e) => !(e is MyException));```
/// to find the first exception in the chain that isn't one defined by this
/// applicating (assuming a heirarchy of exceptions starting with
/// `MyException`).
///
/// Or maybe there is a heirarchy of `CommunicationException` that can be found
/// as `exception.isCaused((e) => e is CommuncationException)` which would find
/// the `ConnectionException` assuming it's a subclass of
/// `CommunicationException`.
///
/// The chain of objects can also be searched simply by iterating back through
/// `causedBy` after checking that each implements `causedBy` mixin.
///
mixin CausedBy {
  /// An object which is the immediate cause of the [this] object.
  Object? get causedBy;

  /// Trace back along [causedBy] references returning the first object
  /// that satisfies the [isCause] predicate provided. If none is found
  /// null is returned.
  ///
  /// [isCause] will be called for each object, starting with this,
  /// and working back while the [causedBy] objects have this mixin.
  ///
  Object? isCaused(bool Function(Object o) isCause) {
    Object? check = this;

    while (check != null) {
      if (isCause(check)) {
        return check;
      }

      check = check is CausedBy ? check.causedBy : null;
    }

    return null;
  }

  /// Return the last (or only) object in the [causedBy] chain.
  static Object rootCause(Object start) {
    Object root = start;

    while (root is CausedBy) {
      final check = root.causedBy;
      if (check != null) {
        root = check;
      } else {
        break;
      }
    }

    return root;
  }

  /// Format a message for an exception using [base], [vars] and [opts].
  ///
  /// The [base] string will be followed by "key=value" pairs from [vars],
  /// separated by spaces and then followed by "key=value" pairs from [opts]
  /// where the value is not empty and ending with [causedBy] appended, if not
  /// null.
  ///
  /// All parts of the resulting message are built from a too complex set of
  /// functions which can overidden to customize the output.
  ///
  /// The output format:
  /// ```
  ///  base: v1=value1 v2=value2 o1=value1 o2=value2 causedBy: base:...
  ///  ^   ^ ^  ^    ^         ^ ^  ^    ^         ^ ^
  ///  |---| |  |    |         | |  |    |         | |
  ///  |formatBase   |         | |  |    |         | |
  ///  |     |  |----|         | |  |----|         | |---------------->
  ///  |     |  |formatValue   | |  |formatValue   | |formatCausedBy
  ///  |     |-------|         | |-------|         |
  ///  |     |formatVarItem    | |formatOptItem    |
  ///  |     |-----------------| |-----------------|
  ///  |     |formatVars         |formatOpts
  ///  |     |formatVarsValue    |formatOptsValues
  ///  |     |--------------------------------------------------------
  ///  |------------------------------------------------------------------
  ///  |formatParts
  ///  |formatMessage
  /// ```
  /// There are some additional methods that control the formatting:
  /// * formatValues - joins the output from formatVars and formatOpts and is
  ///   used as the default formatting by separating them with a space
  /// * formatItem - creates the formatting for a single item name=value and is
  ///   used as the default by formatVarItem and formatOptItem
  /// * formatQuotedString - checks a string using needsQuote and will add any
  ///   quotation marks. Default quotes strings containing whitespace or empty
  ///   strings so they don't vanish formatNullValue - returns a representation
  ///   for null. Default is <null>
  /// * isNoValue - predicate to decide if a value isn't there to remove
  ///   optional variables output
  ///
  /// There are probably others -- check the code.

  String exceptionMessage(String base, MsgVarList vars, MsgVarList opts) {
    return formatMessage(base, vars, opts);
  }

  /// Top of the message formatting tree.
  ///
  /// Can be overridden to complete control resulting message.
  String formatMessage(String base, MsgVarList vars, MsgVarList opts) {
    return formatParts(
      formatBase(base),
      formatVarsValues(formatVars(vars)),
      formatOptsValues(formatOpts(opts)),
      formatCausedBy(),
    );
  }

  /// Combine all the messages parts: base, vars, opt, cause into a single
  /// string.
  ///
  /// Default is to end earch non-empty part with a space and trim the result.
  String formatParts(
      String basePart, String varsPart, String optPart, String causePart) {
    return ((basePart.isEmpty ? '' : "$basePart ") +
            (varsPart.isEmpty ? '' : "$varsPart ") +
            (optPart.isEmpty ? '' : "$optPart ") +
            (causePart.isEmpty ? '' : "$causePart "))
        .trim();
  }

  /// Format the [base] of the message; the thing that appears at the
  /// beginning (in the default format) of the message.
  ///
  /// Default appends ':' to the string
  String formatBase(String base) {
    return "$base:";
  }

  /// Format the list of values from formatXXXX methods to combine them for
  /// placing in the message.
  ///
  /// Default is to join separated by a single space.
  String formatValues(List<String> values) {
    return values.isEmpty ? '' : values.join(' ');
  }

  /// Format the list of formatted var values to a single string for display.
  ///
  /// Default is to use [formatValues] which can be overridden.
  String formatVarsValues(List<String> values) {
    return formatValues(values);
  }

  /// Format the list of formatted opt values to a single string for display.
  ///
  /// Default is to use [formatValues] which can be overridden.
  String formatOptsValues(List<String> values) {
    return formatValues(values);
  }

  /// Format the list of variables [vars].
  ///
  /// Default is name=value using [formatVarItem].
  List<String> formatVars(MsgVarList vars) {
    return vars.map(formatVarItem).toList();
  }

  /// Format the list of optional variables [vars].
  ///
  /// Default is to ignore any value which is null or the empty String otherwise
  /// format using [formatVarItem].
  List<String> formatOpts(MsgVarList opts) {
    return opts.map(formatOptItem).whereType<String>().toList();
  }

  /// Format [causedBy]
  ///
  /// Default returns '' if null and 'causedBy: causedby.toString().
  String formatCausedBy() => causedBy == null ? '' : "causedBy: $causedBy";

  /// Format the var item [def].
  ///
  /// Default is name=value where value is formatted by [formatValue].
  String formatVarItem(MsgVarDef def) =>
      formatItem(def.n, formatValue(def.n, def.v));

  /// Format opt(ional) item [def].
  ///
  /// Default is to return null, meaning don't display this item, if
  /// the [isNoValue] predicate returns true.
  String? formatOptItem(MsgVarDef def) {
    final value = formatValue(def.n, def.v);
    return isNoValue(value) ? null : formatItem(def.n, value);
  }

  /// Format [name] and [value] into an item string.
  ///
  /// Default is "$name=$value".
  String formatItem(String name, String value) {
    return "$name=$value";
  }

  /// Check if [value] needs to be quoted.
  ///
  /// Default is to quote any string with whitespace or empty string.
  bool needsQuote(String value) =>
      value.isEmpty || value.contains(RegExp(r'\s'));

  /// If [s] needs quoting as determined by [needsQuote] do it.
  ///
  /// Default is to surround with single quotes.
  String formatQuotedString(String s) => needsQuote(s) ? "'$s'" : s;

  /// Format a value to add to the message.
  ///
  /// If [value] is a function with one parameter it will be called with the
  /// name as the parameter otherwise default is to use toString() or call
  /// [formatNullValue] for nulls.
  String formatValue(String name, Object? value) {
    final v = (value != null && value is Function) ? value(name) : value;

    final valueString = v == null ? formatNullValue() : v.toString();
    return formatQuotedString(valueString);
  }

  /// Return a representation for a null value.
  ///
  /// Default is '<null>'.
  String formatNullValue() {
    return '<null>';
  }

  /// Check for our no value condition which is an empty string, a literal
  /// empty string ("''") or the null value format.
  bool isNoValue(String value) =>
      value.isEmpty || value == "''" || value == formatNullValue();
}
