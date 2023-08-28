/// Exception message formatting helper types
typedef MsgVarDef = ({String n, Object? v});
typedef MsgVarList = List<MsgVarDef>;

/// Mixin to augment classes with a reference to another object.
/// Used by [Exception] subclasses to create a chain of references of exceptions
/// that can be search to determine a source of exceptions to simplify error
/// handling while still maintaining a history of the exception for logging
/// and debugging purposes.
///
/// Also adds a method to generate toString() for exceptions in a standard
/// format and adds the nested exceptions to the resulting string.

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

  /// Format a message for an exception using [base], [vars] and [opts].
  ///
  /// The [base] string will be followed by "key=value" pairs from [vars],
  /// separated by spaces and then followed by "key=value" pairs from [opts] where
  /// the value is not empty and ending with [causedBy] appended, if not null.
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
  /// Default is to ignore any value which is null or whose toString() return
  /// an empty string, otherwise format using [formatVarItem].
  List<String> formatOpts(MsgVarList opts) {
    return opts
        .where((e) => e.v != null && e.v.toString().isNotEmpty)
        .map(formatVarItem)
        .toList();
  }

  /// Format [causedBy]
  ///
  /// Default returns '' if null and 'causedBy: causedby.toString().
  String formatCausedBy() => causedBy == null ? '' : "causedBy: $causedBy";

  /// Format the var item [def].
  ///
  /// Default is name=value where value is formatted by [formatValue].
  String formatVarItem(MsgVarDef def) {
    return "${def.n}=${formatValue(def.v)}";
  }

  /// Format an opt item [def].
  ///
  /// Default is to ignore (return '') if the value is null or toString()
  /// [isEmpty] otherwise format using [formatVarItem].
  String formatOptItem(MsgVarDef def) {
    if (def.v == null || def.toString().isEmpty) {
      return '';
    }

    return formatVarItem(def);
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
  /// Default is to use toString() or call [formatNullValue] for nulls.
  String formatValue(Object? value) {
    final valueString = value == null ? formatNullValue() : value.toString();
    return formatQuotedString(valueString);
  }

  /// Return a representation for a null value.
  ///
  /// Default is '<null>'.
  String formatNullValue() {
    return '<null>';
  }
}
