<?php

/**
 * Zend Framework (http://framework.zend.com/)
 *
 * @link      http://github.com/zendframework/ZendSkeletonApplication for the canonical source repository
 * @copyright Copyright (c) 2005-2012 Zend Technologies USA Inc. (http://www.zend.com)
 * @license   http://framework.zend.com/license/new-bsd New BSD License
 */
namespace Application;

use Zend\Mvc\ModuleRouteListener;
use Zend\Mvc\MvcEvent;
use Zend\ModuleManager\Feature\AutoloaderProviderInterface;
use Zend\Session\Container;
use Zend\Session\Config\SessionConfig;
use Zend\Session\SessionManager;
use Zend\Authentication\Storage;
use Zend\Authentication\AuthenticationService;
use Zend\Authentication\Adapter\DbTable as DbTableAuthAdapter;
use Zend\Db\ResultSet\ResultSet;
use Zend\Db\TableGateway\TableGateway;
use Application\Model\MemreasConstants;
use Application\Model\TransactionReceiver;
use Application\Model\Subscription;
use Application\Model\SubscriptionTable;
use Application\Model\AccountDetail;
use Application\Model\AccountDetailTable;
use Application\Model\AccountBalances;
use Application\Model\AccountBalancesTable;
use Application\Model\Account;
use Application\Model\AccountTable;
use Application\Model\Transaction;
use Application\Model\TransactionTable;
use Application\Model\PaymentMethod;
use Application\Model\PaymentMethodTable;
use Application\Model\TranscodeTransaction;
use Application\Model\TranscodeTransactionTable;
use Application\Model\User;
use Application\Model\UserTable;
use Application\Model;

class Module {
	public function onBootstrap(MvcEvent $e) {
		$e->getApplication ()->getServiceManager ()->get ( 'translator' );
		$eventManager = $e->getApplication ()->getEventManager ();
		$serviceManager = $e->getApplication ()->getServiceManager ();
		$moduleRouteListener = new ModuleRouteListener ();
		$moduleRouteListener->attach ( $eventManager );
		// no need for session
		// $this->bootstrapSession($e);
	}
	public function bootstrapSession($e) {
		$session = $e->getApplication ()->getServiceManager ()->get ( 'Zend\Session\SessionManager' );
		$session->start ();
		
		$container = new Container ( 'user' );
		if (! isset ( $container->init )) {
			$session->regenerateId ( true );
			$container->init = 1;
		}
	}
	public function getConfig() {
		return include __DIR__ . '/config/module.config.php';
	}
	public function getAutoloaderConfig() {
		return array (
				'Zend\Loader\StandardAutoloader' => array (
						'namespaces' => array (
								__NAMESPACE__ => __DIR__ . '/src/' . __NAMESPACE__ 
						) 
				) 
		);
	}
	public function getServiceConfig() {
		return array (
				'factories' => array (
						// ZF2 Session Setup...
						/*
						 * 'Zend\Session\SessionManager' => function ($sm) {
						 * $config = $sm->get('config');
						 * if (isset($config['session'])) {
						 * $session = $config['session'];
						 *
						 * $sessionConfig = null;
						 * if (isset($session['config'])) {
						 * $class = isset($session['config']['class']) ?
						 * $session['config']['class'] :
						 * 'Zend\Session\Config\SessionConfig';
						 * //$options = isset($session['config']['options']) ?
						 * $session['config']['options'] : array();
						 *
						 * //setting this for AWS permissions error
						 * //Note: must specify full path
						 * //$options['save_path'] = getcwd()."/data/session/";
						 * $options['save_path'] = "/var/app/data/session/";
						 *
						 * $sessionConfig = new $class();
						 * $sessionConfig->setOptions($options);
						 *
						 * }
						 *
						 * $sessionStorage = null;
						 * if (isset($session['storage'])) {
						 * $class = $session['storage'];
						 * $sessionStorage = new $class();
						 * }
						 *
						 * $sessionSaveHandler = null;
						 * if (isset($session['save_handler'])) {
						 * // class should be fetched from service manager since
						 * it will require constructor arguments
						 * $sessionSaveHandler =
						 * $sm->get($session['save_handler']);
						 * }
						 *
						 * $sessionManager = new SessionManager($sessionConfig,
						 * $sessionStorage, $sessionSaveHandler);
						 *
						 * if (isset($session['validator'])) {
						 * $chain = $sessionManager->getValidatorChain();
						 * foreach ($session['validator'] as $validator) {
						 * $validator = new $validator();
						 * $chain->attach('session.validate', array($validator,
						 * 'isValid'));
						 *
						 * }
						 * }
						 * } else {
						 * $sessionManager = new SessionManager();
						 * }
						 * Container::setDefaultManager($sessionManager);
						 * return $sessionManager;
						 * },
						 * 'Application\Model\MyAuthStorage' => function($sm) {
						 * return new
						 * \Application\Model\MyAuthStorage('eventapp');
						 * },
						 * 'AuthService' => function($sm) {
						 * //My assumption, you've alredy set dbAdapter
						 * //and has users table with columns : user_name and
						 * pass_word
						 * //that password hashed with md5
						 * $dbAdapter = $sm->get(MemreasConstants::MEMREASDB);
						 * $dbTableAuthAdapter = new
						 * DbTableAuthAdapter($dbAdapter,
						 * 'user', 'username', 'password', 'MD5(?)');
						 *
						 * $authService = new AuthenticationService();
						 * $authService->setAdapter($dbTableAuthAdapter);
						 * $authService->setStorage($sm->get('Application\Model\MyAuthStorage'));
						 * return $authService;
						 * },
						 */
						
						// Database Tables...
						'Application\Model\TranscodeTransactionTable' => function ($sm) {
							$tableGateway = $sm->get ( 'TranscodeTransactionTableGateway' );
							$table = new TranscodeTransactionTable ( $tableGateway );
							return $table;
						},
						'TranscodeTransactionTableGateway' => function ($sm) {
						$dbAdapter = $sm->get ( MemreasConstants::TRANSCODERDB);
							$resultSetPrototype = new ResultSet ();
							$resultSetPrototype->setArrayObjectPrototype ( new TranscodeTransaction () );
							return new TableGateway ( 'transcodetransaction', $dbAdapter, null, $resultSetPrototype );
						} 
				) 
		);
	}
}
