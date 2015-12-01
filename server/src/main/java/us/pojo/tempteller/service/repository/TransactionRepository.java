package us.pojo.tempteller.service.repository;

import org.springframework.data.repository.CrudRepository;

import us.pojo.tempteller.model.auth.Transaction;

public interface TransactionRepository extends CrudRepository<Transaction, String> {

}
