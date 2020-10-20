# 🔏 Data Field

![SwiftUI iOS 14](https://img.shields.io/badge/SwiftUI-iOS_14-blue?style=flat)
![SPM Compatible](https://img.shields.io/badge/SPM-compatible-orange?style=flat)
![Release Version](https://img.shields.io/github/v/tag/marcusrossel/data-field?color=green&include_prereleases&label=release&sort=semver)

A SwiftUI view that wraps a `TextField` to only accept specific data.

## Motivation

SwiftUI's native `TextField` is a great tool to allow users to edit **text** in your app. Oftentimes
what we *actually* want to edit though is data that is not text. And further, it's usually required
that the data fulfills certain requirements.  
`DataField` provides a text field to edit any kind of data, declare constraints on the user's inputs
and gives you options for handling invalid inputs.

## Installation

`DataField` can be installed via [Swift Package Manager](https://swift.org/package-manager/).

If you are using Xcode click `File > Swift Packages > Add Package Dependency` and enter the URL of
`DataField`'s repository: `https://github.com/marcusrossel/data-field.git`.

If you're a framework author and use `DataField` as a dependency, update your `Package.swift` file:

```swift
let package = Package(

    // ...

    dependencies: [
        .package(url: "https://github.com/marcusrossel/data-field.git", from: "0.3.0")
    ],

    // ...
)
```

## Usage

> *All of the examples below are numbered and can be viewed as* SwiftUI Previews *in the
> repository's `Sources > DataField > Previews` directory.*

Let's say we wanted a user to edit the hour-component of a time value. A view for that could look
something like this:

```swift
struct HourView: View {

    @State var hour = 10

    var body: some View {
        // ...
    }
}
```

Now optimally we'd like to pass a binding to `hour` into a `TextField`, because *that* is the data
we want to be editing - but `TextField` only accepts `String` bindings. With a `DataField` though,
we can pass in a binding for any type we like. All we have to do additionally, is to specify how an
instance of that type can be retrieved *from* a `String` and how it can be converted *to* a
`String`:

```swift
// Example 1

struct HourView: View {

    @State var hour = 10

    var body: some View {
        DataField("Hour", data: $hour) { text in
            Int(text)
        } dataToText: { data in
            "\(data)"
        }
    }
}
```

The first closure is `textToData` and the second is `dataToText`.  
In `dataToText` we specify that an `Int` should be represented as a `String` by directly converting
it to one.  
In `textToData` we basically do the same in reverse. Note here that `Int(text)` returns a `String?`.
Returning `nil` in `textToData` is the way of telling the data field that the given text was not
valid data. The consequence is that, if a user tries committing such text, the data field won't
write it to the binding.  
This last fact also allows us to specify constraints on the data we accept:

```swift
// Example 2

struct HourView: View {

    @State var hour = 10

    var body: some View {
        DataField("Hour", data: $hour) { text in
            guard let validHour = Int(text), (0..<24).contains(validHour) else { return nil }
            return validHour
        } dataToText: { data in
            "\(data)"
        }
    }
}
```

Here we say that we only convert given text to data if the text is convertible to an `Int` and its
value is within `0..<24`.  
So how do we inform the user about invalid text? For that purpose a `DataField` can take another
closure to which it will send any invalid text:

```swift
// Example 3

struct HourView: View {

    @State var hour = 10
    @State var textIsInvalid = false

    var body: some View {
        VStack {
            DataField("Hour", data: $hour) { text in
                guard let validHour = Int(text), (0..<24).contains(validHour) else { return nil }
                return validHour
            } dataToText: { data in
                "\(data)"
            } invalidText: { text in
                textIsInvalid = (text != nil)
            }

            if textIsInvalid {
                Text("Please enter a number between 0 and 23!")
            }
        }
    }
}
```

In the example above, we simply record whether the current text is invalid in a separate state
variable. We then use that state variable's value to determine whether or not a hint should be
shown below the text field. Note that this hint will only ever show *while* the data field is being
edited.

If we want to be even more specific about how data is shown, `DataField` has one tool we can use.
We can specify different formats for our data depending on whether the field is actively being
edited or not.
E.g. let's say we wanted to format the hour values as `<hour>:00h`, but when the user starts
editing, all they should see is `XX`. We can achieve this as follows:

```swift
// Example 4

struct HourView: View {

    @State var hour = 10
    @State var textIsInvalid = false

    var body: some View {
        VStack {
            DataField("Hour", data: $hour) { text in
                guard let validHour = Int(text), (0..<24).contains(validHour) else { return nil }
                return validHour
            } dataToText: { data in
                "\(data):00h"
            } editableText: { data in
                "\(data)"
            } invalidText: { text in
                textIsInvalid = (text != nil)
            }

            if textIsInvalid {
                Text("Please enter a number between 0 and 23!")
            }
        }
    }
}
```

When an `editableText` closure is passed, it is used to represent the data when the data field is in
edit mode. When it is not in edit mode the `dataToText` closure is used as usual.

### Safe Fields

For the examples above to work *well*, we have to be sure that we have full control over the binding
that we pass into the data field. That is, even if the value of the binding is set to something that
is invalid, the data field will still show that value when not being actively edited. This can lead
to an unpleasant user experience.

`DataField` allows you to avoid this problem, by not using a binding at all. Instead we can
initialize a data field by passing it a `sink` closure, which will receive any valid data values
committed to the data field:

```swift
// Example 5

struct HourView: View {

    @Binding var hour: Int

    var body: some View {
        DataField("Hour", initialData: hour) { text in
            guard let validHour = Int(text), (0..<24).contains(validHour) else { return nil }
            return validHour
        } dataToText: { data in
            if let data = data { return "\(data)" } else { return "" }
        } sink: { validData in
            hour = validData
        }
    }
}
```

The `initialData` parameter allows us to pass an initial value. But note, that if that value is not
valid data, it won't be shown by the data field!

The main downside of this approach is that it's less convenient than just passing a binding -
especially if you *know* that the value won't be changed from the outside. But in the example above
the binding comes from *outside* of the view, so we don't know who else might write to it.

### String-Convertible Data

`DataField` has some affordances for using `String` and `String`-convertible data. Since `dataToText` and
`textToData` are redundant in those cases, there are some special initialzers for `DataField`.

When working with `String` data, we can pass a `constraint` closure, which returns a `Bool` indicating whether
or not a given `String` is considered *valid*:

```swift
// Example 6

struct NameView: View {

    @State var name = "marcus"

    var body: some View {
        VStack {
            DataField("Hour", data: $name) { text in
                !text.isEmpty
            }
        }
    }
}
```

When working with data that is `CustomStringConvertible` or `LosslessStringConvertible`, we can
simply drop the corresponding conversion closures if we want to:

> *Note*: `LosslessStringConvertible` implies conformance to `CustomStringConvertible`. 

```swift
// Example 7

enum CoinSide: String, LosslessStringConvertible {

    case heads
    case tails

    var description: String { rawValue }
    init?(_ string: String) { self.init(rawValue: string) }
}

struct CoinView: View {

    @State var coinSide: CoinSide = .heads

    var body: some View {
        VStack {
            DataField("Coin Side", data: $coinSide)
        }
    }
}
```
