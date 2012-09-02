//
//  Tangle.js
//  Tangle 0.1.0
//
//  Created by Bret Victor on 5/2/10.
//  (c) 2011 Bret Victor.  MIT open-source license.
//
//  ------ model ------
//
//  var tangle = new Tangle(rootElement, model);
//  tangle.setModel(model);
//
//  ------ variables ------
//
//  var value = tangle.getValue(variableName);
//  tangle.setValue(variableName, value);
//  tangle.setValues({ variableName:value, variableName:value });
//
//  ------ UI components ------
//
//  Tangle.classes.myClass = {
//     initialize: function (element, options, tangle, variable) { ... },
//     update: function (element, value) { ... }
//  };
//  Tangle.formats.myFormat = function (value) { return "..."; };
//

var Tangle = this.Tangle = function (rootElement, modelClass) {

    var tangle = this;
    tangle.element = rootElement;
    tangle.setModel = setModel;
    tangle.getValue = getValue;
    tangle.setValue = setValue;
    tangle.setValues = setValues;

    var _model;
    var _nextSetterID = 0;
    var _setterInfosByVariableName = {};   //  { varName: { setterID:7, setter:function (v) { } }, ... }
    var _varargConstructorsByArgCount = [];


    //----------------------------------------------------------
    //
    // construct

    initializeElements();
    setModel(modelClass);
    return tangle;


    //----------------------------------------------------------
    //
    // elements

    function initializeElements() {
        var elements = rootElement.getElementsByTagName("*");
        var interestingElements = [];
        
        // build a list of elements with class or data-var attributes
        
        for (var i = 0, length = elements.length; i < length; i++) {
            var element = elements[i];
            if (element.getAttribute("class") || element.getAttribute("data-var")) {
                interestingElements.push(element);
            }
        }

        // initialize interesting elements in this list.  (Can't traverse "elements"
        // directly, because elements is "live", and views that change the node tree
        // will change elements mid-traversal.)
        
        for (var i = 0, length = interestingElements.length; i < length; i++) {
            var element = interestingElements[i];
            
            var varNames = null;
            var varAttribute = element.getAttribute("data-var");
            if (varAttribute) { varNames = varAttribute.split(" "); }

            var views = null;
            var classAttribute = element.getAttribute("class");
            if (classAttribute) {
                var classNames = classAttribute.split(" ");
                views = getViewsForElement(element, classNames, varNames);
            }
            
            if (!varNames) { continue; }
            
            var didAddSetter = false;
            if (views) {
                for (var j = 0; j < views.length; j++) {
                    if (!views[j].update) { continue; }
                    addViewSettersForElement(element, varNames, views[j]);
                    didAddSetter = true;
                }
            }
            
            if (!didAddSetter) {
                var formatAttribute = element.getAttribute("data-format");
                var formatter = getFormatterForFormat(formatAttribute, varNames);
                addFormatSettersForElement(element, varNames, formatter);
            }
        }
    }
            
    function getViewsForElement(element, classNames, varNames) {   // initialize classes
        var views = null;
        
        for (var i = 0, length = classNames.length; i < length; i++) {
            var clas = Tangle.classes[classNames[i]];
            if (!clas) { continue; }
            
            var options = getOptionsForElement(element);
            var args = [ element, options, tangle ];
            if (varNames) { args = args.concat(varNames); }
            
            var view = constructClass(clas, args);
            
            if (!views) { views = []; }
            views.push(view);
        }
        
        return views;
    }
    
    function getOptionsForElement(element) {   // might use dataset someday
        var options = {};

        var attributes = element.attributes;
        var regexp = /^data-[\w\-]+$/;

        for (var i = 0, length = attributes.length; i < length; i++) {
            var attr = attributes[i];
            var attrName = attr.name;
            if (!attrName || !regexp.test(attrName)) { continue; }
            
            options[attrName.substr(5)] = attr.value;
        }
         
        return options;   
    }
    
    function constructClass(clas, args) {
        if (typeof clas !== "function") {  // class is prototype object
            var View = function () { };
            View.prototype = clas;
            var view = new View();
            if (view.initialize) { view.initialize.apply(view,args); }
            return view;
        }
        else {  // class is constructor function, which we need to "new" with varargs (but no built-in way to do so)
            var ctor = _varargConstructorsByArgCount[args.length];
            if (!ctor) {
                var ctorArgs = [];
                for (var i = 0; i < args.length; i++) { ctorArgs.push("args[" + i + "]"); }
                var ctorString = "(function (clas,args) { return new clas(" + ctorArgs.join(",") + "); })";
                ctor = eval(ctorString);   // nasty
                _varargConstructorsByArgCount[args.length] = ctor;   // but cached
            }
            return ctor(clas,args);
        }
    }
    

    //----------------------------------------------------------
    //
    // formatters

    function getFormatterForFormat(formatAttribute, varNames) {
        if (!formatAttribute) { formatAttribute = "default"; }

        var formatter = getFormatterForCustomFormat(formatAttribute, varNames);
        if (!formatter) { formatter = getFormatterForSprintfFormat(formatAttribute, varNames); }
        if (!formatter) { log("Tangle: unknown format: " + formatAttribute); formatter = getFormatterForFormat(null,varNames); }

        return formatter;
    }
        
    function getFormatterForCustomFormat(formatAttribute, varNames) {
        var components = formatAttribute.split(" ");
        var formatName = components[0];
        if (!formatName) { return null; }
        
        var format = Tangle.formats[formatName];
        if (!format) { return null; }
        
        var formatter;
        var params = components.slice(1);
        
        if (varNames.length <= 1 && params.length === 0) {  // one variable, no params
            formatter = format;
        }
        else if (varNames.length <= 1) {  // one variable with params
            formatter = function (value) {
                var args = [ value ].concat(params);
                return format.apply(null, args);
            };
        }
        else {  // multiple variables
            formatter = function () {
                var values = getValuesForVariables(varNames);
                var args = values.concat(params);
                return format.apply(null, args);
            };
        }
        return formatter;
    }
    
    function getFormatterForSprintfFormat(formatAttribute, varNames) {
        if (!sprintf || !formatAttribute.test(/\%/)) { return null; }

        var formatter;
        if (varNames.length <= 1) {  // one variable
            formatter = function (value) {
                return sprintf(formatAttribute, value);
            };
        }
        else {
            formatter = function (value) {  // multiple variables
                var values = getValuesForVariables(varNames);
                var args = [ formatAttribute ].concat(values);
                return sprintf.apply(null, args);
            };
        }
        return formatter;
    }

    
    //----------------------------------------------------------
    //
    // setters
    
    function addViewSettersForElement(element, varNames, view) {   // element has a class with an update method
        var setter;
        if (varNames.length <= 1) {
            setter = function (value) { view.update(element, value); };
        }
        else {
            setter = function () {
                var values = getValuesForVariables(varNames);
                var args = [ element ].concat(values);
                view.update.apply(view,args);
            };
        }

        addSetterForVariables(setter, varNames);
    }

    function addFormatSettersForElement(element, varNames, formatter) {  // tangle is injecting a formatted value itself
        var span = null;
        var setter = function (value) {
            if (!span) { 
                span = document.createElement("span");
                element.insertBefore(span, element.firstChild);
            }
            span.innerHTML = formatter(value);
        };

        addSetterForVariables(setter, varNames);
    }
    
    function addSetterForVariables(setter, varNames) {
        var setterInfo = { setterID:_nextSetterID, setter:setter };
        _nextSetterID++;

        for (var i = 0; i < varNames.length; i++) {
            var varName = varNames[i];
            if (!_setterInfosByVariableName[varName]) { _setterInfosByVariableName[varName] = []; }
            _setterInfosByVariableName[varName].push(setterInfo);
        }
    }

    function applySettersForVariables(varNames) {
        var appliedSetterIDs = {};  // remember setterIDs that we've applied, so we don't call setters twice
    
        for (var i = 0, ilength = varNames.length; i < ilength; i++) {
            var varName = varNames[i];
            var setterInfos = _setterInfosByVariableName[varName];
            if (!setterInfos) { continue; }
            
            var value = _model[varName];
            
            for (var j = 0, jlength = setterInfos.length; j < jlength; j++) {
                var setterInfo = setterInfos[j];
                if (setterInfo.setterID in appliedSetterIDs) { continue; }  // if we've already applied this setter, move on
                appliedSetterIDs[setterInfo.setterID] = true;
                
                setterInfo.setter(value);
            }
        }
    }
    

    //----------------------------------------------------------
    //
    // variables

    function getValue(varName) {
        var value = _model[varName];
        if (value === undefined) { log("Tangle: unknown variable: " + varName);  return 0; }
        return value;
    }

    function setValue(varName, value) {
        var obj = {};
        obj[varName] = value;
        setValues(obj);
    }

    function setValues(obj) {
        var changedVarNames = [];

        for (var varName in obj) {
            var value = obj[varName];
            var oldValue = _model[varName];
            if (oldValue === undefined) { log("Tangle: setting unknown variable: " + varName);  continue; }
            if (oldValue === value) { continue; }  // don't update if new value is the same

            _model[varName] = value;
            changedVarNames.push(varName);
        }
        
        if (changedVarNames.length) {
            applySettersForVariables(changedVarNames);
            updateModel();
        }
    }
    
    function getValuesForVariables(varNames) {
        var values = [];
        for (var i = 0, length = varNames.length; i < length; i++) {
            values.push(getValue(varNames[i]));
        }
        return values;
    }

                    
    //----------------------------------------------------------
    //
    // model

    function setModel(modelClass) {
        var ModelClass = function () { };
        ModelClass.prototype = modelClass;
        _model = new ModelClass;

        updateModel(true);  // initialize and update
    }
    
    function updateModel(shouldInitialize) {
        var ShadowModel = function () {};  // make a shadow object, so we can see exactly which properties changed
        ShadowModel.prototype = _model;
        var shadowModel = new ShadowModel;
        
        if (shouldInitialize) { shadowModel.initialize(); }
        shadowModel.update();
        
        var changedVarNames = [];
        for (var varName in shadowModel) {
            if (!shadowModel.hasOwnProperty(varName)) { continue; }
            if (_model[varName] === shadowModel[varName]) { continue; }
            
            _model[varName] = shadowModel[varName];
            changedVarNames.push(varName);
        }
        
        applySettersForVariables(changedVarNames);
    }


    //----------------------------------------------------------
    //
    // debug

    function log (msg) {
        if (window.console) { window.console.log(msg); }
    }

};  // end of Tangle


//----------------------------------------------------------
//
// components

Tangle.classes = {};
Tangle.formats = {};

Tangle.formats["default"] = function (value) { return "" + value; };

