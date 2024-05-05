import XCTest
@testable import RocketParsing
import Markdown

final class RocketParsingTests: XCTestCase {
    let sampleMarkdown = """
    @Meta(
        title: "From C to Swift - Part 1",
        description: "Learn to how to integrate C system libraries into your Swift code",
        tags: "swift swiftpm c",
    )
    
    # Creating Tables
    
    Like a `List` you can create a table by passing in an array of `Identifiable` items to a `Table` struct which is followed by a builder. Unlike a `List`, you do not create views in the builder. Instead you define **columns**. Tables must be defined in terms of columns.

    > [!note]
    > Before iOS 16/macOS 13, you were limited to 10 columns per table. This limit was due to how the column builder was implemented. In iOS 16/macOS 13, Apple expanded `Group` to be composable with columns, allowing us to make more than 10 columns per table.

    Below is a simple example of a table.
    ``` swift
    Table(users) {
        TableColumn("First Name", value: \\.firstName)

        TableColumn("Last Name") { user in
            Text(user.lastName)
        }
    }
    ```

    This **will** produce a *table* with two columns, the first display the first name of the user, while the second has the last name.

    Notice the two different ways of how the columns are created. The first way is a nice shortcut if what you want to display is a simple String, while the latter offers more fine-grained control over. You can pass as complex a view here as you want, so long as it looks nice in a table cell. Let's add a few more columns.
    
    - List item 1
    - List item 2
        - Sublist item 1
        - Sublist item 2
    - List item 3
    
    1. Ordered List
    2. Ordered List 2
    1. Ordered List 3
    
    ---
    
    ## Header 2
    
    Paragraph
    """
    
    func testExample() throws {
        var converter = HTMLConverter(markdown: sampleMarkdown)
        
        let html = converter.generateHTML()
        
        print("""
        ## Original document:
        \(Document(parsing: sampleMarkdown, options: .parseBlockDirectives).debugDescription())
        """)
        
        print("""
        ## HTML
        \(html)
        """)
    }
}
