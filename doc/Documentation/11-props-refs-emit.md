# Communication: Props, $refs, and $emit

As of v1.1.0, BlaiseVue supports advanced component communication following Vue.js patterns, while maintaining Object Pascal typing and syntax.

## Props (Parent -> Child)
Used to pass data from the parent component to the child.

- **Static Props:** Regular attributes.
- **Dynamic Props:** Prefix `:` or `b-bind:`.

```html
<user-card name="Blaise" :id="userId"></user-card>
```

## $refs (Direct Access)
Allows the parent to call methods that are inside the child component.

1. Add `b-ref="name"` to the tag.
2. In Pascal, use `TJSObject(this['$refs'])['name']`.

```pascal
procedure ResetChild;
var
  child: TJSObject;
begin
  child := TJSObject(TJSObject(this['$refs'])['myComp']);
  TJSFunction(child['childMethod']).apply(child['$data'], []);
end;
```

## $emit (Child -> Parent)
Allows the child to notify the parent about events.

1. In the child, call `this['$emit']('event-name', data)`.
2. In the parent, listen with `@event-name="methodInParent"`.

```html
<!-- In Parent -->
<child-comp @child-click="OnChildClick"></child-comp>
```

```pascal
// In Child
procedure Clicked;
begin
  this['$emit']('child-click', 'Hello parent!');
end;
```
