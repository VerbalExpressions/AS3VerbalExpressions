/*!
 * VerbalExpressions ActionScript 3 Library v0.1
 * https://github.com/jehna/VerbalExpressions
 *
 *
 * Released under the MIT license
 * http://jquery.org/license
 *
 * Date: 2013-07-19
 *
 */

package
{
	
	public class VerExp
	{
		// Variables to hold the whole
		// expression construction in order
		private var prefixes:String = "";
		private var source:String = "";
		private var suffixes:String = "";
		private var modifiers:String = "gm"; // default to global multiline matching
		private var regExp:RegExp;
		
		public function VerExp()
		{
		
		}
		
		/**
		 * Sanitation function for adding
		 * anything safely to the expression
		 * @param	value
		 */
		private function sanitize(value:String):String
		{
			return value.replace(/[^\w]/g, sanitizeCharacter);
		}
		
		private function sanitizeCharacter(... args):String
		{
			return "\\" + args[0];
		}
		
		/**
		 * Function to add stuff to the
		 * expression.
		 * @param	value
		 * @return
		 */
		private function add(value:String):VerExp
		{
			source += value || "";
			compile();
			return this;
		}
		
		private function compile():void
		{
			regExp = new RegExp(prefixes + source + suffixes, modifiers);
		}
		
		/**
		 * Start of line function
		 * @param	enable
		 * @return
		 */
		public function startOfLine(enable:Boolean = true):VerExp
		{
			prefixes = enable ? "^" : "";
			compile();
			return this;
		}
		
		/**
		 * End of line function
		 * @param	enable
		 * @return
		 */
		public function endOfLine(enable:Boolean = true):VerExp
		{
			suffixes = enable ? "$" : "";
			compile();
			return this;
		}
		
		/**
		 * We try to keep the syntax as
		 * user-friendly as possible.
		 * So we can use the "normal"
		 * behaviour to split the "sentences"
		 * naturally.
		 * @param	value
		 * @return
		 */
		public function then(value:String):VerExp
		{
			value = sanitize(value);
			add("(?:" + value + ")");
			return this;
		}
		
		/**
		 * And because we can't start with
		 * "then" function, we create an alias
		 * to be used as the first function
		 * of the chain.
		 * @param	value
		 * @return
		 */
		public function find(value:String):VerExp
		{
			return then(value);
		}
		
		/**
		 * Maybe is used to add values with ?
		 * @param	value
		 * @return
		 */
		public function maybe(value:String):VerExp
		{
			value = sanitize(value);
			add("(?:" + value + ")?");
			return this;
		}
		
		/**
		 * Any character any number of times
		 * @return
		 */
		public function anything(value:String):VerExp
		{
			add("(?:.*)");
			return this;
		}
		
		/**
		 * Anything but these characters
		 * @param	value
		 * @return
		 */
		public function anythingBut(value:String):VerExp
		{
			value = sanitize(value);
			add("(?:[^" + value + "]*)");
			return this;
		}
		
		/**
		 * Any character at least one time
		 * @return
		 */
		public function something():VerExp
		{
			add("(?:.+)");
			return this;
		}
		
		/**
		 * Any character at least one time except for these characters
		 * @param	value
		 * @return
		 */
		public function somethingBut(value:String):VerExp
		{
			value = sanitize(value);
			add("(?:[^" + value + "]+)");
			return this;
		}
		
		/**
		 * Line break
		 * @return
		 */
		public function lineBreak():VerExp
		{
			add("(?:(?:\\n)|(?:\\r\\n))"); // Unix + windows CLRF
			return this;
		}
		
		/**
		 * Tab
		 * @return
		 */
		public function tab():VerExp
		{
			add("\\t");
			return this;
		}
		
		/**
		 * Any alphanumeric
		 * @return
		 */
		public function word():VerExp
		{
			add("\\w+");
			return this;
		}
		
		/**
		 * Any given character
		 * @param	value
		 * @return
		 */
		public function anyOf(value:String):VerExp
		{
			value = sanitize(value);
			add("[" + value + "]");
			return this;
		}
		
		/**
		 * Shorthand for anyOf
		 * @param	value
		 * @return
		 */
		public function any(value:String):VerExp
		{
			return (anyOf(value));
		}
		
		/**
		 * Usage: .range( from, to [, from, to ... ] )
		 * @param	...args
		 * @return
		 */
		public function range(... args):VerExp
		{
			var value:String = "[";
			
			for (var from:int = 0; from < args.length; from += 2)
			{
				var to:int = from + 1;
				
				if (args.length <= to)
					break;
				
				var fromCharacter:String = sanitize(args[from]);
				var toCharacter:String = sanitize(args[to]);
				
				value += from + "-" + to;
			}
			
			value += "]";
			
			add(value);
			return this;
		}
		
		private function addModifier(modifier:String):VerExp
		{
			if (modifiers.indexOf(modifier) == -1)
			{
				modifiers += modifier;
			}
			compile();
			return this;
		}
		
		private function removeModifier(modifier:String):VerExp
		{
			modifiers = modifiers.replace(modifier, "");
			compile();
			return this;
		}
		
		/**
		 * Case-insensitivity modifier
		 * @param	enable
		 * @return
		 */
		public function withAnyCase(enable:Boolean):VerExp
		{
			if (enable)
				addModifier("i");
			else
				removeModifier("i");
			
			return this;
		}
		
		/**
		 * Enables dotall modifier, making "anything" function match newline character (\n).
		 * @param	enable
		 * @return
		 */
		public function anythingMatchesNewLine(enable:Boolean):VerExp
		{
			if (enable)
				addModifier("s");
			else
				removeModifier("s");
			
			return this;
		}
		
		/**
		 * Allows to include space characters in regular expression
		 * @param	enable
		 * @return
		 */
		public function ignoreWhitespaceCharacters(enable:Boolean):VerExp
		{
			if (enable)
				addModifier("x");
			else
				removeModifier("x");
			
			return this;
		}
		
		/**
		 * Default behaviour is with "g" modifier,
		 * so we can turn this another way around
		 * than other modifiers
		 * @param	enable
		 * @return
		 */
		public function stopAtFirst(enable:Boolean):VerExp
		{
			if (enable)
				removeModifier("g");
			else
				addModifier("g");
			
			return this;
		}
		
		/**
		 * Multiline, also reversed
		 * @param	enable
		 * @return
		 */
		public function searchOneLine(enable:Boolean):VerExp
		{
			if (enable)
				removeModifier("m");
			else
				addModifier("m");
			
			return this;
		}
		
		/**
		 * Provided character one or more times. If provided strings already includes quantifier, it is passed as is.
		 * @param	value
		 * @return
		 */
		public function multiple(value:String):VerExp
		{
			switch (value.substr(-1))
			{
				case "*": 
				case "+": 
					break;
				default: 
					value += "+";
			}
			add(value);
			return this;
		}
		
		/**
		 * Adds alternative expressions
		 * @param	value
		 * @return
		 */
		public function or(value:String):VerExp
		{
			prefixes += "(?:";
			suffixes = ")" + suffixes;
			
			add(")|(?:");
			
			if (value)
				then(value);
			
			return this;
		}
		
		/**
		 * Starts a capturing group
		 * @return
		 */
		public function beginCapture():VerExp
		{
			//add the end of the capture group to the suffixes for now so compilation continues to work
			suffixes += ")";
			add("(");
			
			return this;
		}
		
		/**
		 * Ends a capturing group
		 * @return
		 */
		public function endCapture():VerExp
		{
			//remove the last parentheses from the suffixes and add to the regex itself
			suffixes = suffixes.substring(0, suffixes.length - 1);
			add(")");
			
			return this;
		}
		
		/**
		 * Shorthand function for the
		 * String.replace function to
		 * give more logical flow if, for
		 * example, we're doing multiple
		 * replacements on one regexp.
		 * @param	source
		 * @param	value
		 * @return
		 */
		public function replace(source:String, value:Object):String
		{
			return source.replace(regExp, value);
		}
		
		/**
		 * Tests for the match of the regular expression in the given string.
		 * @param	string
		 * @return
		 */
		public function test(string:String):Boolean
		{
			return regExp.test(string);
		}
		
		/**
		 * Performs a search for the regular expression on the given string str.
		 * @param	string
		 * @return If there is no match, null; otherwise, an object with the following properties:
		 *
		 *     An array, in which element 0 contains the complete matching substring, and
		 *   other elements of the array (1 through n) contain substrings that match parenthetical groups
		 *   in the regular expression index  The character position of the matched substring within
		 *   the stringinput  The string (str)
		 */
		public function exec(string:String):Object
		{
			return regExp.exec(string);
		}
		
		/**
		 * Converts expression to RegExp
		 * @return If there is a match, true; otherwise, false.
		 */
		public function toRegExp():RegExp
		{
			compile();
			return regExp;
		}
		
		public function toString():String
		{
			return "/" + prefixes + source + suffixes + "/" + modifiers;
		}
	
	}

}