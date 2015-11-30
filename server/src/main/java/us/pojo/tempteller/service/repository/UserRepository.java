package us.pojo.tempteller.service.repository;

import org.springframework.data.repository.CrudRepository;

import us.pojo.tempteller.model.auth.User;

public interface UserRepository extends CrudRepository<User, String> {

}
