USING: io io.streams.nested help.markup help.syntax ;

HELP: (with-stream-style)
{ $values { "quot" "a quotation" } { "style" "a hashtable" } { "stream" "an output stream" } }
{ $description "Wraps the stream in a " { $link style-stream } " and calls the quotation in a dynamic scope where " { $link stdio } " is rebound to the new stream." }
{ $notes "This word provides a default implementation for the " { $link with-stream-style } " generic word that methods can call. It should not be used outside this context, since some streams require a custom definition of " { $link with-stream-style } "." } ;
