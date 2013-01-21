# Flex 4.5 based MySQL Query Browser

Ever needed a simple, web based tool to query your SQL databases? This query browser not only offers the simple interface but also (limited) support to query large tables.

Data is displayed in a Flex 4 interface using the [AsyncListView collection wrapper](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/collections/AsyncListView.html) class for data paging.

## Motivation

- Provide people who start using SQL with a simple, inviting interface to improve their data retrieval skills.

- Get grip on the new Flex 4 data paging features, combined with [Robotlegs](http://www.robotlegs.org/) to tidy up the client side code and [Zend AMF](http://framework.zend.com/download/amf) for remoting.

## Requirements

- PHP 5+ (5.2.4+ recommended by Zend)
- MySQL
- Flex 4+

## Features

- Not really feature rich, but give it a chance.

### Database structure at a glance	

- Table names including number of rows
- Field names with type information and a special icon for easy identification of the primary key

### Very simple query builder 	

- Click on table or field nodes to get the corresponding SQL Query

### Query history

- Run previous queries 

### Limited large table support

- Run simple queries (including a primary) on tables with millions of rows.

## Installation

### 1. Configure the Database

I suggest to [create](http://dev.mysql.com/doc/refman/5.1/en/create-user.html) or use a user with just `SELECT` [privileges](http://dev.mysql.com/doc/refman/5.1/en/privileges-provided.html) to the database you wish to make accessible to the query browser. 

### 2. Configure PHP access to the database

Set the user credentials for the database user in the `php/DBHandler.php` class.

    class DBHandler {
	
        // Set database connection parameters
        const DB_HOST = 'localhost';
		const DB_NAME = 'imdb';
		const DB_USER = 'imdb';
		const DB_PASS = '*imdb*';
	
	[...]


### 3. Configure Flex remoting

Set the remoting endpoint in the `services-config.xml` file.

    <endpoint uri="http://showcase.to-fuse.ch/QueryBrowser/php/" class="flex.messaging.endpoints.AMFEndpoint"/> 
    
There is an optional configuration parameter found in class `ch.tofuse.querybrowser.config.QueryRemoteConfig` to adjust the (data) page size.

    public static const DATA_PAGE_SIZE:int = 500;
	
### Limitations

- Data paging is getting really slow with complex queries (without primary key) and large result sets
- Queries on tables with non-consecutive primary keys is possible, and can be enabled calling the designated method (`QueryBrowser->executeSimpleQueryNonConsecutive()`). However, data paging performance is again really lousy.
- ... and many more.


### More

- [Visit the blog post](http://www.smartcode.ch/blog/flex-4-5-mysql-query-browser/)  
- Check out the [demo](http://showcase.smartcode.ch/query-browser/).




 
