---
date: "2017-04-22T20:45:24+02:00"
title: "Spring Data repository with empty IN clause."
draft: false
tags: ['java','spring-boot','spring-data','sql','jpa']
---

The problem I've stabled upon started with a [spring data repository]
(https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#repositories.core-concepts) like this:
```java
public interface SampleRepository extends CrudRepository<Sample, Integer>{
    @Query("select s from Sample s where s.id in :ids")
    List<Sample> queryIn(@Param("ids") List<Integer> ids);
}
```
Actual query was of course more complicated that this. Complex enough to justify not using a [query method]
(https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#jpa.query-methods). 
The problem emerges when you run this method with an empty collection as argument:
```java
repository.queryIn(Collections.emptyList());
```
The result is database dependent. There no problem on H2, but on HSQLDB (and also at least on MSSQL) you get:
```text
Caused by: org.hsqldb.HsqlException: unexpected token: )
	at org.hsqldb.error.Error.parseError(Unknown Source)
	at org.hsqldb.ParserBase.unexpectedToken(Unknown Source)
	...
```
Syntax error in generated SQL query? How come? Lets first look at how `in` clause is handled by hibernate. 
Starting with a query that is run with a non-empty list parameter
```java
repository.queryIn(Arrays.asList(1, 2, 3));
```
the SQL generated by hibernate looks something like this
```sql
select
    sample0_.id as id1_0_,
    sample0_.name as name2_0_ 
from
    sample sample0_ 
where
    sample0_.id in (
        ? , ? , ?
    )
```
Turns out that hibernate can't pass an array directly to the `in` clause. It has to create a sql parameter for 
every entry in the collection.  
Aha, so when the collection passed to the query is empty, the SQL becomes:
```sql
select
    sample0_.id as id1_0_,
    sample0_.name as name2_0_ 
from
    sample sample0_ 
where
    sample0_.id in ()
```
Here is where the syntax error comes in. The SQL standard does require at least one [value expression]
(http://jakewheat.github.io/sql-overview/sql-2011-foundation-grammar.html#_8_4_in_predicate) between the parenthesis.
So the closing bracket `)`, right after `(`, causes HSQLDB's SQL parser to throw a syntax error. Quite rightly though. 

# Solutions

First of all, let me point out, that a corresponding `find..In()`
[query method](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#jpa.query-methods)
works fine for an empty 
parameter:
```java
public interface SampleRepository extends CrudRepository<Sample, Integer>{
    List<Sample> findByIdIn(List<Integer> ids);
}
```
So the following test passes:
```java
@Test
public void findByIdIn() {
    List<Sample> result = repository.findByIdIn(Collections.emptyList());
    assertThat(result, empty());
}
```
But what to do, when the query is complex or would yeld a ridiculously long query method name like 
```java
findByProduct_Category_EmployeeResponsible_Departament_Location_CityIn(
   List<City> cities
)
```
A custom `@Query` won't work, but there's another option. 
[JPA Criteria API](https://docs.oracle.com/javaee/6/tutorial/doc/gjitv.html). This is what 
[Spring Data JPA is actually using] (https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#jpa.query-methods.query-creation)
under the hood to generate JPA queries from query methods. 

The bridge between Criteria API and Spring Data repositories is called 
[Specifications](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#specifications).
First thing is to make your repository implement `JpaSpecificationExecutor<T>`:
```java
public interface SampleRepository extends 
    CrudRepository<Sample, Integer>, 
    JpaSpecificationExecutor<Sample>  {
    
    // ...
    
}
```
Now you can call `findAll(Specification<T>)` method on your repository: 
```java
repository.findAll(new Specification<Sample>() {
    @Override
    public Predicate toPredicate(Root<Sample> root, 
        CriteriaQuery<?> criteriaQuery, CriteriaBuilder criteriaBuilder) {
        // ....
    }
})
```
Great! You get a place, where you can *dynamically* create any `WHERE` clause using Criteria API.

The criteria corresponding to SQL's
```SQL
WHERE id IN (1,2,3)
```
is
```java
root.get("id").in(1,2,3);
//or 
List<Integer> ids = Arrays.asList(1,2,3);
root.get("id").in(ids);
```
It's worth noting here, that most of the Criteria API tutorials use the type-safe generated 
[Metamodel](https://docs.oracle.com/javaee/6/tutorial/doc/gjiup.html) classes. 
But it might be an overkill to set up persistence provider’s annotation processor just to handle a few queries. 
Most of your queries will probably be handled fine by Spring Data Query methods. Fortunately there's an option to 
use string's instead of Metamodel properties, like in the example above.

Just using `root.get("id").in(ids)` will not save you from the possible SQL syntax error when `ids` are empty. But as
the query is created dynamically, you have full control whether to include the `in()` statement or not. 
To mimic the spring's standard `find...In()` behaviour use this predicate:
```java
@Override
public Predicate toPredicate(Root<Sample> root, 
        CriteriaQuery<?> criteriaQuery, CriteriaBuilder criteriaBuilder) {
    if (ids.isEmpty()) {
        return criteriaBuilder.disjunction();
    } else {
        return root.get("id").in(ids);
    }
}
```
The mystic `disjunction()`
is a simple clause that is always `FALSE`. The exact 
[javadoc](https://docs.oracle.com/javaee/6/api/javax/persistence/criteria/CriteriaBuilder.html#disjunction()) states:
  
> Create a disjunction (with zero disjuncts). A disjunction with zero disjuncts is false.

All right. It's a working solution, but it can be made less verbose when using Java 8. First step is the replace 
the anonymous class with a lambda:
```java
findAll((root, criteriaQuery, criteriaBuilder) -> {
    if (ids.isEmpty()) {
        return criteriaBuilder.conjunction()
    } else {
        return root.get("id").in(ids);
    }
});
```
In this exact case it may be tempting to even use the conditional (`?:`) operator, so that the brackets (`{}`) 
and `return` can be omitted:
```java
findAll((root, criteriaQuery, criteriaBuilder) ->
    ids.isEmpty() ? criteriaBuilder.conjunction() : root.get("id").in(ids)
);
```

The other thing is, that it would be nice to have this method available directly on the repository, not in some service
class. Here, next new Java 8 feature come in handy - interface 
[default methods](https://docs.oracle.com/javase/tutorial/java/IandI/defaultmethods.html).
```java
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface SampleRepository extends CrudRepository<Sample, Integer>,
    JpaSpecificationExecutor<Sample> {
  
  // ...
 
  default List<Sample> findIn(List<Integer> ids) {
    return findAll((root, criteriaQuery, criteriaBuilder) ->
      ids.isEmpty() 
        ? criteriaBuilder.conjunction() 
        : root.get("id").in(ids)
    );
  }
}
```
New you can call this custom query method like any other repository method:
```java

@Test
public void nonEmptySpecIn() {
    List<Integer> ids = Arrays.asList(1, 2, 3);
    List<Sample> result = repository.findIn(ids);
    
    assertThat(
        result.stream()
            .map(sample -> sample.id)
            .collect(toList()),
        equalTo(ids)
    );
}
```
## Select all on empty `IN`

Common case with `IN` clauses is when you have a search filter like:

> Select categories:  
> [x] Home & Garden  
> [ ] Beauty, Health & Food  
> [ ] Sport & Outdoors  

In this case, when the selected categories collection is empty, you want this filter to be ignored.  
Having a predicate creation method, this change becomes trivial;
```java
default List<Sample> findIn(List<Integer> ids) {
    return findAll((root, criteriaQuery, criteriaBuilder) -> {
        if (ids.isEmpty()) {
            return null; // or criteriaBuilder.conjunction()
        } else {
            return root.get("id").in(ids);
        }
    });
}
```
As for the `null` here. The `toPredicate()` documentation says that you are not allowed to return it here. 
But it turn out that [spring data handles it](https://jira.spring.io/browse/DATAJPA-300) rather correctly. 
I've placed a 
[pull request](https://github.com/spring-projects/spring-data-jpa/pull/197) to update the javadoc.
 
The complete sample code used in this article in [available on 
github](https://github.com/rzymek/sandbox/tree/spring-boot-jpa-empty-in).