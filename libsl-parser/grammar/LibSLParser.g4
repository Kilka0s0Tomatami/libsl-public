parser grammar LibSLParser;

options { tokenVocab = LibSLLexer; }

/*
 * entry rule
 * specification starts with header block ('libsl', 'library' and other keywords), then
 * semantic types section and declarations (automata and extension functions)
 */
file
   :   header?
       globalStatement*
       EOF
   ;

globalStatement
   :   ImportStatement
   |   IncludeStatement
   |   typesSection
   |   typealiasStatement
   |   typeDefBlock
   |   enumBlock
   |   annotationDecl
   |   actionDecl
   |   topLevelDecl
   ;

topLevelDecl
   :   automatonDecl
   |   functionDecl
   |   variableDecl
   ;

/*
 * header section
 * includes 'libsl' keyword with LibSL version, 'library' keyword with name of the library, and any of these optionally:
 * 'version', 'language' and 'url'
 */
header:
   (LIBSL lslver=DoubleQuotedString SEMICOLON)
   (LIBRARY libraryName=Identifier)
   (VERSION ver = DoubleQuotedString)?
   (LANGUAGE lang=DoubleQuotedString)?
   (URL link=DoubleQuotedString)?
   SEMICOLON;

/* typealias statement
 * syntax: typealias name = origintlType
 */
typealiasStatement
   :   annotationUsage* TYPEALIAS left=typeIdentifier ASSIGN_OP right=typeIdentifier SEMICOLON
   ;

/* type define block
 * syntax: type full.name { field1: Type; field2: Type; ... }
 */
typeDefBlock
   :   annotationUsage* TYPE type=typeIdentifier targetType? whereConstraints? (L_BRACE typeDefBlockStatement* R_BRACE)?
   ;

targetType
   :   (IS typeIdentifier)? for_CPP=Identifier typeList
   ;


typeList
   :  typeIdentifier (COMMA typeIdentifier)*
   ;

typeDefBlockStatement
   :   variableDecl
   |   functionDecl
   ;

/* enum block
 * syntax: enum Name { Variant1=0; Variant2=1; ... }
 */
enumBlock
   :   annotationUsage* ENUM typeIdentifier L_BRACE enumBlockStatement* R_BRACE
   ;

enumBlockStatement
   :   Identifier ASSIGN_OP integerNumber SEMICOLON
   ;

/* semantic types section
 * syntax types { semanticTypeDeclaration1; semanticTypeDeclaration2; ... }
 */
typesSection
   :   TYPES L_BRACE semanticTypeDecl* R_BRACE
   ;

semanticTypeDecl
   :    simpleSemanticType
   |    enumSemanticType
   ;

/* simple semantic type
 * syntax: semanticTypeName (realTypeName);
 */
simpleSemanticType
   :   annotationUsage* semanticName=typeIdentifier L_BRACKET realName=typeIdentifier R_BRACKET SEMICOLON
   ;

/* block semantic type
 * syntax: semanticTypeName (realTypeName) {variant1: 0; variant2: 1; ...};
 */
enumSemanticType
   :   annotationUsage* semanticName=Identifier L_BRACKET realName=typeIdentifier R_BRACKET L_BRACE enumSemanticTypeEntry+ R_BRACE
   ;

enumSemanticTypeEntry
   :   Identifier COLON expressionAtomic SEMICOLON
   ;

/* annotation declaration
 * syntax: annotation Something(
 *             variable1: int = 0,
 *             variable2: int = 1
 *         );
 */
annotationDecl
   :   ANNOTATION name=Identifier L_BRACKET annotationDeclParams? R_BRACKET SEMICOLON
   ;

annotationDeclParams
   :   annotationDeclParamsPart (COMMA annotationDeclParamsPart)* (COMMA)?
   ;

annotationDeclParamsPart
   :   nameWithType (ASSIGN_OP expression)?
   ;

actionDecl
   :   annotationUsage*
   DEFINE ACTION generic? actionName=Identifier L_BRACKET actionDeclParamList? R_BRACKET (COLON actionType=typeIdentifier)? whereConstraints? SEMICOLON
   ;

actionDeclParamList
   :   actionParameter (COMMA actionParameter)* (COMMA)?
   ;

actionParameter
   :   annotationUsage* name=Identifier COLON type=typeIdentifier
   ;

/* automaton declaration
 * syntax: [@Annotation1(param: type)
 *         @Annotation2(param: type]
 *         automaton Name [(constructor vars)] : type { statement1; statement2; ... }
 */
automatonDecl
   :   annotationUsage* AUTOMATON CONCEPT_CPP? name=periodSeparatedFullName (L_BRACKET constructorVariables* R_BRACKET)?
   COLON type=typeExpression implementedConcepts*
   L_BRACE automatonStatement* R_BRACE
   ;

constructorVariables
   :   annotationUsage* keyword=(VAR|VAL) nameWithType (COMMA)?
   |   annotationUsage* keyword=(VAR|VAL) nameWithType ASSIGN_OP assignmentRight (COMMA)?
   ;

automatonStatement
   :   automatonStateDecl
   |   automatonShiftDecl
   |   constructorDecl
   |   destructorDecl
   |   procDecl
   |   functionDecl
   |   variableDecl
   ;

implementedConcepts
   :   implements=Identifier concept_CPP (COMMA concept_CPP)*
   ;

concept_CPP
   :   name=Identifier
   ;

/* state declaration
 * syntax: one of {initstate; state; finishstate} name;
 */
automatonStateDecl
   :   keyword=(INITSTATE | STATE | FINISHSTATE) identifierList SEMICOLON
   ;

/* shift declaration
 * syntax: shift from -> to(function1; function2(optional arg types); ...)
 * syntax: shift (from1, from2, ...) -> to(function1; function2(optional arg types); ...)
 */
automatonShiftDecl
   :   SHIFT from=Identifier MINUS_ARROW to=Identifier BY functionsListPart SEMICOLON
   |   SHIFT from=Identifier MINUS_ARROW to=Identifier BY L_SQUARE_BRACKET functionsList? R_SQUARE_BRACKET SEMICOLON
   |   SHIFT from=L_BRACKET identifierList R_BRACKET MINUS_ARROW to=Identifier BY functionsListPart SEMICOLON
   |   SHIFT from=L_BRACKET identifierList R_BRACKET MINUS_ARROW to=Identifier BY L_SQUARE_BRACKET functionsList? R_SQUARE_BRACKET SEMICOLON
   ;

functionsList
   :   functionsListPart (COMMA functionsListPart)* (COMMA)?
   ;

functionsListPart
   :   name=Identifier (L_BRACKET typeIdentifier? (COMMA typeIdentifier)* R_BRACKET)?
   ;

/* variable declaration with optional initializers
 * syntax: var NAME [= { new AutomatonName(args); atomic }]
 */
variableDecl
   :   annotationUsage* keyword=(VAR|VAL) nameWithType SEMICOLON
   |   annotationUsage* keyword=(VAR|VAL) nameWithType ASSIGN_OP assignmentRight SEMICOLON
   ;

nameWithType
   :  name=Identifier COLON type=typeExpression
   ;

/*
 * syntax: one.two.three<T>
 */

typeExpression
   :   typeIdentifier
   |   typeExpression AMPERSAND  typeExpression
   |   typeExpression BIT_OR typeExpression
   ;

typeIdentifier
   :   (asterisk=ASTERISK)? name=typeIdentifierName generic?
   ;

generic
   :   (L_ARROW typeArgument (COMMA typeArgument)* R_ARROW)
   ;

typeArgument
    : typeIdentifier
    | typeIdentifierBounded
    ;

typeIdentifierBounded
    : genericBound typeIdentifier
    ;

variableAssignment
   :   qualifiedAccess op=ASSIGN_OP assignmentRight SEMICOLON
   |   qualifiedAccess op=(PLUS_EQ | MINUS_EQ | ASTERISK_EQ | SLASH_EQ | PERCENT_EQ) assignmentRight SEMICOLON
   |   qualifiedAccess op=(AMPERSAND_EQ | OR_EQ | XOR_EQ) assignmentRight SEMICOLON
   |   qualifiedAccess op=(R_SHIFT_EQ | L_SHIFT_EQ) assignmentRight SEMICOLON
   ;

assignmentRight
   :   expression
   ;

callAutomatonConstructorWithNamedArgs
   :   NEW name=periodSeparatedFullName generic? L_BRACKET (namedArgs)? R_BRACKET
   ;

namedArgs
   :   argPair (COMMA argPair)* (COMMA)?
   ;

argPair
   :   name=STATE ASSIGN_OP expressionAtomic
   |   name=Identifier ASSIGN_OP expression
   ;

headerWithAsterisk
   :   ASTERISK DOT
   ;

constructorDecl
   :   constructorHeader (SEMICOLON | L_BRACE functionBody R_BRACE)
   ;

constructorHeader
   :   annotationUsage* CONSTRUCTOR headerWithAsterisk? functionName=Identifier? L_BRACKET functionDeclArgList? R_BRACKET
   (COLON functionType=typeIdentifier)?
   ;

destructorDecl
   :   destructorHeader (SEMICOLON | L_BRACE functionBody R_BRACE)?
   ;

destructorHeader
   :   annotationUsage* DESTRUCTOR headerWithAsterisk? functionName=Identifier? L_BRACKET functionDeclArgList? R_BRACKET
   (COLON functionType=typeIdentifier)?
   ;

procDecl
   :   procHeader (SEMICOLON | L_BRACE functionBody R_BRACE)
   ;

procHeader
   :   annotationUsage* PROC headerWithAsterisk? functionName=Identifier generic? L_BRACKET functionDeclArgList? R_BRACKET
   (COLON functionType=typeExpression)? whereConstraints?
   ;
/*
 * syntax: @Annotation
 *         fun name(@annotation arg1: type, arg2: type, ...) [: type] [preambule] { statement1; statement2; ... }
 * In case of declaring extension-function, name must look like Automaton.functionName
 */
functionDecl
   :   functionHeader (SEMICOLON | (L_BRACE functionBody R_BRACE)?)
   ;

functionHeader
   :   annotationUsage* modifier=Identifier? FUN (automatonName=periodSeparatedFullName DOT)? headerWithAsterisk? functionName=Identifier generic?
   L_BRACKET functionDeclArgList? R_BRACKET (COLON functionType=typeExpression)? whereConstraints?
   ;

functionDeclArgList
   :   parameter (COMMA parameter)*
   ;

parameter
   :   annotationUsage* name=Identifier COLON type=typeExpression
   ;

/* annotation
 * syntax: @annotationName(args)
 */
annotationUsage
   :   AT Identifier (L_BRACKET annotationArgs* R_BRACKET)?
   ;

functionContract
   :   requiresContract
   |   ensuresContract
   |   assignsContract
   ;

functionBody
   :   functionContract* functionBodyStatement*
   ;

functionBodyStatement
   :   variableAssignment
   |   variableDecl
   |   ifStatement
   |   expression SEMICOLON
   ;

ifStatement
   :   IF expression L_BRACE functionBodyStatement* R_BRACE (elseStatement)?
   |   IF expression functionBodyStatement (elseStatement)?
   ;

elseStatement
   :   ELSE L_BRACE functionBodyStatement* R_BRACE
   |   ELSE functionBodyStatement
   ;

/* semantic action
 * syntax: action ActionName(args)
 */
actionUsage
   :   ACTION Identifier generic? L_BRACKET expressionsList? R_BRACKET
   ;

procUsage
   :   qualifiedAccess generic? L_BRACKET expressionsList? R_BRACKET
   ;

expressionsList
   :   expression (COMMA expression)* (COMMA)?
   ;

annotationArgs
   :   argName? expression (COMMA)?
   ;

argName
   :   name=Identifier ASSIGN_OP
   ;

/* requires contract
 * syntax: requires [name:] condition
 */
requiresContract
   :   REQUIRES (name=Identifier COLON)? expression SEMICOLON
   ;

/* ensures contract
 * syntax: ensures [name:] condition
 */
ensuresContract
   :   ENSURES (name=Identifier COLON)? expression SEMICOLON
   ;

/* assigns contract
 * syntax: assigns [name:] condition
 */
assignsContract
   :   ASSIGNS (name=Identifier COLON)? expression SEMICOLON
   ;

/*
 * expression
 */
expression
   :   expressionAtomic
   // primaryNoNewArray
   |   qualifiedAccess apostrophe=APOSTROPHE
   |   qualifiedAccess
   |   procUsage
   |   actionUsage
   |   callAutomatonConstructorWithNamedArgs
   |   lbracket=L_BRACKET expression rbracket=R_BRACKET
   |   hasAutomatonConcept

   // unaryExpression + unaryExpressionNotPlusMinus
   |   unaryOp=(PLUS | MINUS | TILDE | EXCLAMATION) expression

   // castExpression
   |   expression typeOp=AS typeIdentifier

   // multiplicativeExpression
   |   expression op=(ASTERISK | SLASH | PERCENT) expression

   // additiveExpression
   |   expression op=(PLUS | MINUS) expression

   // shiftExpression
   |   expression bitShiftOp expression

   // relationalExpression
   |   expression op=(L_ARROW | R_ARROW | L_ARROW_EQ | R_ARROW_EQ) expression
   |   expression typeOp=IS typeIdentifier

   // equalityExpression
   |   expression op=(EQ | EXCLAMATION_EQ) expression

   // inclusiveOrExpression
   |   expression op=BIT_OR expression
   // exclusiveOrExpression
   |   expression op=XOR expression
   // andExpression
   |   expression op=AMPERSAND expression

   // conditionalOrExpression
   |   expression op=LOGIC_OR expression
   // conditionalAndExpression
   |   expression op=DOUBLE_AMPERSAND expression
   ;

hasAutomatonConcept
   :   qualifiedAccess has=Identifier name=Identifier
   ;

bitShiftOp
   :   lShift
   |   rShift
   |   uRShift
   |   uLShift
   ;

lShift
   :   L_ARROW L_ARROW
   ;

rShift
   :   R_ARROW R_ARROW
   ;

uRShift
   :   R_ARROW R_ARROW R_ARROW
   ;

uLShift
   :   L_ARROW L_ARROW L_ARROW
   ;

expressionAtomic
   :   primitiveLiteral
   |   arrayLiteral
   |   qualifiedAccess
   ;

primitiveLiteral
   :   integerNumber
   |   floatNumber
   |   DoubleQuotedString
   |   CHARACTER
   |   bool_CPP=(TRUE | FALSE)
   |   nullLiteral=NULL_CPP
   ;

qualifiedAccess
   :   periodSeparatedFullName
   |   qualifiedAccess L_SQUARE_BRACKET expression R_SQUARE_BRACKET (DOT qualifiedAccess)?
   |   simpleCall DOT qualifiedAccess
   |   simpleCall DOT procUsage
   ;

simpleCall
   :   Identifier generic? L_BRACKET qualifiedAccess R_BRACKET
   ;

identifierList
   :   Identifier (COMMA Identifier)*
   ;

arrayLiteral
   :   L_SQUARE_BRACKET expressionsList? R_SQUARE_BRACKET
   ;

periodSeparatedFullName
   :   Identifier
   |   Identifier (DOT Identifier)*
   |   BACK_QOUTE Identifier (DOT Identifier)* BACK_QOUTE
   |   UNBOUNDED
   ;

integerNumber
   :   (MINUS | PLUS)? IntegerLiteral
   ;

floatNumber
   :   (MINUS | PLUS)? FloatingPointLiteral
   ;

suffix
   :   Identifier
   ;

typeConstraint
    : paramName=Identifier COLON paramConstraint=typeArgument
    ;

whereConstraints
    : WHERE typeConstraint (COMMA typeConstraint)*
    ;

genericBound
   :   bound=(IN | OUT)
   ;

typeIdentifierName
   :   periodSeparatedFullName
   |   primitiveLiteral
   ;