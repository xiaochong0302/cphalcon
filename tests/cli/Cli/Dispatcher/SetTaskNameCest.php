<?php

/**
 * This file is part of the Phalcon Framework.
 *
 * (c) Phalcon Team <team@phalcon.io>
 *
 * For the full copyright and license information, please view the LICENSE.txt
 * file that was distributed with this source code.
 */

declare(strict_types=1);

namespace Phalcon\Test\Cli\Cli\Dispatcher;

use CliTester;

/**
 * Class SetTaskNameCest
 */
class SetTaskNameCest
{
    /**
     * Tests Phalcon\Cli\Dispatcher :: setTaskName()
     *
     * @author Phalcon Team <team@phalcon.io>
     * @since  2018-11-13
     */
    public function cliDispatcherSetTaskName(CliTester $I)
    {
        $I->wantToTest('Cli\Dispatcher - setTaskName()');
        $I->skipTest('Need implementation');
    }
}
